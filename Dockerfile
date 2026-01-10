# Stage 1: Build the Flutter Web App
FROM instrumentisto/flutter:latest AS build

WORKDIR /app

# Copy the project files
COPY . .

# Install dependencies and build web
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built assets from the builder stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Add basic Nginx config for SPA (Single Page Application)
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    location / { \
    root /usr/share/nginx/html; \
    index index.html index.htm; \
    try_files $uri $uri/ /index.html; \
    } \
    }' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
