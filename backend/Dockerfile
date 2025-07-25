# =============================================================================
# Backend Node.js Multi-Stage Dockerfile
# =============================================================================
# This Dockerfile creates optimized images for both production and development
# Usage with Docker Compose:
#   - Production: docker-compose up (uses 'production' target)
#   - Development: docker-compose -f docker-compose.dev.yml up (uses 'development' target)

# =============================================================================
# Stage 1: Base Dependencies
# =============================================================================
# This stage installs only production dependencies for smaller final image
FROM node:20-alpine AS dependencies

# Set working directory inside container
WORKDIR /app

# Copy package.json and package-lock.json first for better caching
# Docker will cache this layer if dependencies haven't changed
COPY package*.json ./

# Install only production dependencies and clean npm cache
# --only=production excludes devDependencies for smaller image size
RUN npm ci --only=production && npm cache clean --force

# =============================================================================
# Stage 2: Production Stage
# =============================================================================
# This stage creates the final production image with minimal footprint
FROM node:20-alpine AS production

# Create a non-root user for better security
# Running applications as root is a security risk
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy production dependencies from the dependencies stage
# This keeps the final image lean by excluding devDependencies
COPY --from=dependencies /app/node_modules ./node_modules

# Copy application source code with proper ownership
# --chown ensures files are owned by the nodejs user
COPY --chown=nodejs:nodejs . .

# Switch to non-root user for security
USER nodejs

# Expose the port that the application runs on
# This port should match the PORT environment variable
EXPOSE 5050

# Start the Node.js application
CMD ["npm", "start"]

# =============================================================================
# Stage 3: Development Stage
# =============================================================================
# This stage includes all dependencies and development tools
FROM node:20-alpine AS development

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies for development tools)
RUN npm ci

# Copy source code
# In development, we typically mount the source as a volume for hot reload
COPY . .

# Expose the development port
EXPOSE 5050

# Start the application in development mode
# If you have nodemon installed, you could use: CMD ["npm", "run", "dev"]
CMD ["npm", "start"]





