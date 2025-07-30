# =============================================================================
# Frontend React/Vite Multi-Stage Dockerfile
# =============================================================================
# This Dockerfile creates optimized images for both production and development
# Usage with Docker Compose:
#   - Production: docker-compose up (uses 'production' target, serves via Nginx)
#   - Development: docker-compose -f docker-compose.dev.yml up (uses 'development' target, Vite dev server)

# =============================================================================
# Stage 1: Build Stage
# =============================================================================
# This stage compiles the React application into static files
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first for better Docker layer caching
# If package.json hasn't changed, Docker can reuse the cached layer
COPY package*.json ./

# Install all dependencies including devDependencies needed for building
# React build process requires devDependencies
RUN npm ci

# Copy all source code
COPY . .

# Build the React application for production
# This creates optimized static files in /app/dist
RUN npm run build

# =============================================================================
# Stage 2: Production Stage
# =============================================================================
# This stage serves the built application using Nginx
FROM nginx:alpine AS production

# Copy the built React application from builder stage
# Nginx serves static files from /usr/share/nginx/html
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for HTTP traffic
# Nginx default port for serving web content
EXPOSE 80

# Start Nginx in foreground mode
# -g daemon off; keeps Nginx running for Docker container
CMD ["nginx", "-g", "daemon off;"]

# =============================================================================
# Stage 3: Development Stage
# =============================================================================
# This stage runs Vite development server with hot reload
FROM node:20 AS development

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies including devDependencies
# Development needs all packages for hot reload and debugging
RUN npm ci

# Copy source code
# In development, source is typically mounted as volume for live changes
COPY . .

# Expose Vite development server port
# Vite default development port
EXPOSE 5173

# Start Vite development server
# --host 0.0.0.0 allows external connections from Docker host
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
