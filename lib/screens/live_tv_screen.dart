import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class LiveTVScreen extends StatefulWidget {
  const LiveTVScreen({super.key});

  @override
  State<LiveTVScreen> createState() => _LiveTVScreenState();
}

class _LiveTVScreenState extends State<LiveTVScreen> with AutomaticKeepAliveClientMixin {
  late YoutubePlayerController _controller;
  
  // Initial Channel (ABC News Live - Verified Global Stream)
  String _currentVideoId = 'w_Ma8oQLmSM'; 

  @override
  bool get wantKeepAlive => true; // Keep the video player alive

  final List<Map<String, String>> _channels = [
    {'name': 'ABC News', 'id': 'w_Ma8oQLmSM', 'color': '0xFF1976D2'}, // Global Default
    {'name': 'Al Jazeera', 'id': 'gCNeDWCI0vo', 'color': '0xFFFBC02D'},
    {'name': 'Geo News', 'id': 'O3DPVlynUM0', 'color': '0xFFF57C00'}, // May vary
    {'name': 'ARY News', 'id': 'RqUZ2Fv9l8w', 'color': '0xFFD32F2F'},
    {'name': 'Samaa TV', 'id': 'zOBlI5x-q0I', 'color': '0xFF1976D2'},
    {'name': 'Express News', 'id': 'yumF75_Y4gE', 'color': '0xFFC2185B'},
    {'name': 'Dunya News', 'id': 'I0t8Z8Iq0_o', 'color': '0xFF388E3C'},
    {'name': 'Sky News', 'id': '9Auq9mYxFEE', 'color': '0xFF455A64'}, // Kept if needed, but likely dead
  ];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        playsInline: true,
        strictRelatedVideos: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );
    
    // Set the origin URL (Crucial for live streams to avoid Error 152)
    _controller.loadVideoById(videoId: _currentVideoId);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _changeChannel(String videoId) {
    setState(() {
      _currentVideoId = videoId;
    });
    _controller.loadVideoById(videoId: videoId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
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
          bottom: false, // Allow scrolling behind bottom nav
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildVideoPlayer(),
                    const SizedBox(height: 20), // Spacing between player and grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                         "Select Channel",
                         style: GoogleFonts.orbitron(
                           fontSize: 18,
                           color: Colors.white70,
                           fontWeight: FontWeight.bold,
                         ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), // Bottom padding for nav bar (70 + 30)
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final channel = _channels[index];
                      final isSelected = channel['id'] == _currentVideoId;
                      final color = Color(int.parse(channel['color']!));

                      return GestureDetector(
                        onTap: () => _changeChannel(channel['id']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? color.withValues(alpha: 0.2) 
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? color 
                                  : Colors.white.withValues(alpha: 0.1),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: color,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                channel['name']!,
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _channels.length,
                  ),
                ),
              ),
            ],
          ),
        ),
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
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(Icons.live_tv_rounded, color: Colors.redAccent),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE TV',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Streaming Now',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
             boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
             ]
          ),
          child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
        ),
      ),
    );
  }

  // _buildChannelGrid removed as it is now integrated into CustomScrollView
}
