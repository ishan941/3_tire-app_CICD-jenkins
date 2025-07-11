# For Production:
# docker build --target production -t frontend-prod .
# docker run -p 80:80 frontend-prod

# For Development:
# docker build --target development -t frontend-dev .
# docker run -p 5173:5173 frontend-dev

# Stage 1: Build stage
# Use Node.js Alpine image for smaller size and security
FROM node:20-alpine AS builder

# Set working directory inside the container
WORKDIR /app

# Set environment variable for production build
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Copy package files first for better Docker layer caching
# This allows Docker to cache npm install step if package.json hasn't changed
COPY package*.json ./

# Install all dependencies (including devDependencies needed for build)
RUN npm ci --only=production=false

# Copy the entire source code
COPY . .

# Build the application for production
# This creates optimized static files in the dist directory
RUN npm run build

# Stage 2: Production stage
# Use nginx Alpine image to serve the built static files
FROM nginx:alpine AS production

# Copy the built application from the builder stage
# Copy from /app/dist (Vite's default build output) to nginx's html directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx configuration for better React Router support
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for the web server
EXPOSE 80

# Start nginx server
# Nginx runs in the foreground in containers
CMD ["nginx", "-g", "daemon off;"]

# Stage 3: Development stage (optional)
# This stage can be used for development with hot reload
FROM node:20-alpine AS development

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies including devDependencies
RUN npm ci

# Copy source code
COPY . .

# Expose Vite's default port
EXPOSE 5173

# Start development server with host binding for Docker
CMD ["npm", "run", "dev"]






# FROM node:20

# WORKDIR /app

# # Copy package files
# COPY package*.json ./

# # Install all dependencies including devDependencies
# RUN npm ci

# # Copy source code
# COPY . .

# # Expose Vite's default port
# EXPOSE 5173

# # Start development server with host binding for Docker
# CMD ["npm", "run", "dev"]
  