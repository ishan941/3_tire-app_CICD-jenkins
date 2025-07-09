# For Production:
# docker build --target production -t backend-prod .
# docker run -p 5050:5050 backend-prod

# docker run -p 5050:5050 \
#   -e PORT=5050 \
#   -e MONGO_URI=mongodb+srv://root:toor@cluster0.oadytbk.mongodb.net/ \
#   backend-prod

# # For Development:
# docker build --target development -t backend-dev .
# docker run -p 5050:5050 backend-dev

# Check Health:
# docker ps  # Shows health status
# docker inspect <container_id> | grep Health  # Detailed health info


# for a mongoDB connection
# docker pull mongo:latest

# docker run -d \
#   --name mongo-container \
#   -p 27017:27017 \
#   -e MONGO_INITDB_ROOT_USERNAME=root \
#   -e MONGO_INITDB_ROOT_PASSWORD=toor \
#   -e MONGO_INITDB_DATABASE=mydatabase \
#   mongo

# Now to connect your backend to this MongoDB instance, you can use the following connection string:
# docker run -p 5050:5050 \
#   -e PORT=5050 \
#   -e MONGO_URI=mongodb://root:toor@localhost:27017/mydatabase \
#   backend-prod


# Stage 1: Dependencies stage
# Use Node.js Alpine image for smaller size and security
FROM node:20-alpine AS dependencies

# Set working directory
WORKDIR /app

# Copy package files for dependency installation
# Copying these first allows Docker to cache this layer if dependencies don't change
COPY package*.json ./

# Install only production dependencies
# Using npm ci for faster, reliable, reproducible builds
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Build stage (for any build processes if needed in future)
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies if any build tools are added)
RUN npm ci

# Copy source code
COPY . .

# If you have any build steps in the future (like TypeScript compilation), add them here
# RUN npm run build

# Stage 3: Production stage
FROM node:20-alpine AS production

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy production dependencies from dependencies stage
COPY --from=dependencies /app/node_modules ./node_modules

# Copy application source code
COPY --chown=nodejs:nodejs . .

# Switch to non-root user for security
USER nodejs

# Expose the port the app runs on
EXPOSE 5050

# Add health check to monitor container health
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "const http = require('http'); \
    const options = { hostname: 'localhost', port: 5050, path: '/', timeout: 2000 }; \
    const req = http.request(options, (res) => { process.exit(res.statusCode === 200 ? 0 : 1); }); \
    req.on('error', () => process.exit(1)); \
    req.end();"

# Start the application
CMD ["npm", "start"]

# Stage 4: Development stage (optional for development use)
FROM node:20-alpine AS development

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies including devDependencies
RUN npm ci

# Copy source code
COPY . .

# Expose port for development
EXPOSE 5050

# Use nodemon for development if available, otherwise use npm start
CMD ["npm", "start"]