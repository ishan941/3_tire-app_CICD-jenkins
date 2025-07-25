# Docker Multi-Stage Build Architecture

This project uses Docker multi-stage builds to create optimized containers for both development and production environments.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │    MongoDB      │
│   (React/Vite)  │    │   (Node.js)     │    │   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
│                 │    │                 │    │                 │
│ Production:     │    │ Production:     │    │ Data Storage:   │
│ - Nginx:80      │    │ - Node.js:5050  │    │ - Port:27017    │
│ - Static files  │    │ - API Server    │    │ - Persistent    │
│                 │    │                 │    │   volumes       │
│ Development:    │    │ Development:    │    │                 │
│ - Vite:5173     │    │ - Node.js:5050  │    │                 │
│ - Hot reload    │    │ - Hot reload    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Dockerfile Structure

### Backend Dockerfile (`backend/Dockerfile`)

**Stage 1: Dependencies**
- Installs only production dependencies
- Uses `npm ci --only=production` for faster, reproducible builds
- Cleans npm cache to reduce image size

**Stage 2: Production**
- Creates non-root user for security
- Copies only production dependencies
- Includes health check for container monitoring
- Optimized for minimal attack surface

**Stage 3: Development**
- Includes all dependencies (dev + production)
- Supports volume mounts for hot reload
- Useful for development with `docker-compose.dev.yml`

### Frontend Dockerfile (`frontend/Dockerfile`)

**Stage 1: Builder**
- Compiles React/Vite application
- Accepts `VITE_API_URL` build argument
- Creates optimized static files in `/dist`

**Stage 2: Production**
- Uses Nginx Alpine for serving static files
- Copies built files from builder stage
- Includes custom Nginx configuration for React Router
- Health check ensures Nginx is serving properly

**Stage 3: Development**
- Runs Vite development server
- Supports hot reload with volume mounts
- Exposes port 5173 for development access

## Docker Compose Coordination

### Production (`docker-compose.yml`)

```yaml
# Service Dependencies:
MongoDB → Backend → Frontend

# Build Targets:
backend:
  target: production    # Optimized, secure image
frontend:
  target: production    # Static files + Nginx

# Key Features:
- Health checks for all services
- Proper dependency ordering
- Production environment variables
- Persistent volumes for database
```

### Development (`docker-compose.dev.yml`)

```yaml
# Service Dependencies:
MongoDB → Backend → Frontend

# Build Targets:
backend:
  target: development   # All dependencies + dev tools
frontend:
  target: development   # Vite dev server

# Key Features:
- Volume mounts for hot reload
- Development ports (5173 for frontend)
- Separate containers/networks from production
- Development environment variables
```

## Environment Variables

### Backend
- `PORT`: Server port (5050)
- `MONGO_URI`: MongoDB connection string
- `NODE_ENV`: Environment mode (production/development)

### Frontend
- `VITE_API_URL`: Backend API URL for frontend requests

## Health Checks

All services include health checks:

### MongoDB
```bash
mongosh --eval "db.adminCommand('ping')"
```

### Backend
```javascript
HTTP GET request to http://127.0.0.1:5050/
```

### Frontend
```bash
wget --spider http://127.0.0.1:80
```

## Volume Strategy

### Production
- `mongodb_data`: Database persistence
- `mongodb_config`: MongoDB configuration

### Development
- `mongodb_data_dev`: Separate dev database
- Source code volumes: `./backend:/app` and `./frontend:/app`
- Anonymous volumes for `node_modules` to avoid conflicts

## Security Features

1. **Non-root users**: Both backend and frontend run as non-root
2. **Multi-stage builds**: Minimal final image size
3. **Production dependencies only**: Excludes dev tools in production
4. **Health monitoring**: Container health status tracking
5. **Network isolation**: Custom networks for service communication

## Usage Examples

### Start Production Environment
```bash
docker-compose up -d
```

### Start Development Environment
```bash
docker-compose -f docker-compose.dev.yml up -d
```

### Build Specific Target
```bash
# Backend production
docker build --target production -t backend-prod ./backend

# Frontend development
docker build --target development -t frontend-dev ./frontend
```

### View Logs
```bash
docker-compose logs backend
docker-compose logs frontend
docker-compose logs mongodb
```

This multi-stage approach provides:
- **Flexibility**: Same Dockerfile for dev and prod
- **Optimization**: Smaller production images
- **Security**: Non-root users and minimal attack surface
- **Maintainability**: Clear separation of concerns
- **Performance**: Optimized builds with proper caching
