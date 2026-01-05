import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/live_news_model.dart';
import '../services/news_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Data State
  List<LiveNewsModel> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Interest-Based News State
  final List<String> _categories = [
    'For You',
    'General',
    'Business',
    'Technology',
    'Sports',
    'Entertainment',
    'Health',
    'Science'
  ];
  String _selectedCategory = 'For You';
  List<String> _userInterests = [];

  @override
  void initState() {
    super.initState();
    _loadInterests();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  Future<void> _loadInterests() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userInterests = prefs.getStringList('userInterests') ?? [];
    });
    _fetchNews(); // Initial fetch after loading interests
  }
  
  // ignore: unused_element
  Future<void> _saveInterests(List<String> interests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userInterests', interests);
    setState(() {
      _userInterests = interests;
    });
    // If currently on "For You", refresh
    if (_selectedCategory == 'For You') {
      _fetchNews();
    }
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      List<LiveNewsModel> articles;
      if (_searchController.text.isNotEmpty) {
        articles = await NewsApiService.searchNews(_searchController.text);
      } else if (_selectedCategory == 'For You') {
        if (_userInterests.isEmpty) {
          articles = await NewsApiService.fetchNewsByCategory('General'); 
        } else {
           if (_userInterests.isNotEmpty) {
             articles = await NewsApiService.fetchNewsByCategory(_userInterests.first);
           } else {
             articles = await NewsApiService.fetchTopHeadlines();
           }
        }
      } else {
        articles = await NewsApiService.fetchNewsByCategory(_selectedCategory);
      }
      
      if (mounted) {
        setState(() {
          _articles = articles;
          _isLoading = false;
          _isSearching = false;
        });
        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isSearching = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }



  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _fetchNews();
      return;
    }
    setState(() {
      _isSearching = true;
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final articles = await NewsApiService.searchNews(query);
      if (mounted) {
        setState(() {
          _articles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $urlString'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showManageInterestsDialog() {
    // Temporary list to track changes within dialog
    List<String> tempInterests = List.from(_userInterests);
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16213E),
              title: Text(
                'Manage Interests',
                style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _categories
                      .where((c) => c != 'For You') // Exclude 'For You' from selection
                      .map((category) {
                    final isSelected = tempInterests.contains(category);
                    return CheckboxListTile(
                      title: Text(category, style: GoogleFonts.poppins(color: Colors.white)),
                      value: isSelected,
                      activeColor: Colors.blueAccent,
                      checkColor: Colors.black,
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          if (value == true) {
                            tempInterests.add(category);
                          } else {
                            tempInterests.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveInterests(tempInterests);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [Color(0xFF1D2671), Color(0xFF0A0E21)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchNews,
            color: Colors.blueAccent,
            backgroundColor: const Color(0xFF0A0E21),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildCategoryChips()),
                SliverToBoxAdapter(child: _buildSearchBar()),
                if (_isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.blueAccent),
                    ),
                  )
                else if (_errorMessage != null)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load news',
                            style: GoogleFonts.poppins(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: _fetchNews,
                            child: Text(
                              'Retry',
                              style:
                                  GoogleFonts.poppins(color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_articles.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No news available',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildNewsCard(_articles[index], index),
                        childCount: _articles.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                    _searchController.clear(); // Clear search when changing category
                    _fetchNews();
                  });
                }
              },
              backgroundColor: Colors.transparent,
              selectedColor: Colors.blueAccent,
              labelStyle: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.blueAccent : Colors.white24,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blueAccent.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(Icons.newspaper, color: Colors.blueAccent),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE FEED',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                _isSearching ? 'Search Results' : 'Global Headlines',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.tune, color: Colors.white70),
            tooltip: 'Manage Interests',
            onPressed: _showManageInterestsDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(color: Colors.white),
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          hintText: 'Search topics...',
          hintStyle: GoogleFonts.poppins(color: Colors.white38),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.blueAccent.withValues(alpha: 0.7)),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                  : null,
        ),
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildNewsCard(LiveNewsModel article, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1 > 1.0 ? 0.0 : index * 0.1,
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              index * 0.1 > 1.0 ? 0.0 : index * 0.1,
              1.0,
              curve: Curves.easeIn,
            ),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _launchUrl(article.url),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.urlToImage != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        article.urlToImage!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: 180,
                              color: Colors.blueAccent.withValues(alpha: 0.05),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white24,
                                  size: 40,
                                ),
                              ),
                            ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                article.sourceName,
                                style: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(article.publishedAt),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          article.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
