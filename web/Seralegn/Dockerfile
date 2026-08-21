# Build Stage for Web Frontend
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci || npm install

# Copy source code and build React web assets
COPY . .
RUN npm run build

# Production Stage with Nginx
FROM nginx:alpine

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled static web files
COPY --from=build /app/dist /usr/share/nginx/html

# Create directory for mobile application APK downloads
RUN mkdir -p /usr/share/nginx/html/downloads

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
