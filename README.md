# 3-Tier Docker Application

A full-stack application with React frontend, Node.js/Express backend, and MongoDB database, all containerized with Docker.

## Architecture

- **Frontend**: React with Vite, served by Nginx (Production) or Vite dev server (Development)
- **Backend**: Node.js with Express API
- **Database**: MongoDB with authentication

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+

## Quick Start (Production)

1. **Clone and navigate to the project:**
   ```bash
   cd "3 tier-docker"
   ```

2. **Build and start all services:**
   ```bash
   docker-compose up -d
   ```

3. **Access the application:**
   - Frontend: http://localhost
   - Backend API: http://localhost:5050
   - MongoDB: localhost:27017

4. **Stop the application:**
   ```bash
   docker-compose down
   ```

## Development Mode

For development with hot reloading and volume mounts:

1. **Start development environment:**
   ```bash
   docker-compose -f docker-compose.dev.yml up -d
   ```

2. **Access the application:**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:5050
   - MongoDB: localhost:27017

3. **Stop development environment:**
   ```bash
   docker-compose -f docker-compose.dev.yml down
   ```

## Available Commands

### Production Commands
```bash
# Start all services in background
docker-compose up -d

# Start all services with logs
docker-compose up

# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: This will delete database data)
docker-compose down -v

# View logs
docker-compose logs

# View logs for specific service
docker-compose logs backend
docker-compose logs frontend
docker-compose logs mongodb

# Rebuild and start
docker-compose up --build

# Scale specific services (if needed)
docker-compose up --scale backend=2
```

### Development Commands
```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up -d

# Stop development environment
docker-compose -f docker-compose.dev.yml down

# View development logs
docker-compose -f docker-compose.dev.yml logs

# Rebuild development containers
docker-compose -f docker-compose.dev.yml up --build
```

## Service Details

### MongoDB
- **Image**: mongo:7-jammy
- **Port**: 27017
- **Credentials**: 
  - Username: `root`
  - Password: `toor`
  - Database: `mydatabase`
- **Data Persistence**: Named volumes for data and config
- **Health Check**: MongoDB ping command

### Backend (Node.js/Express)
- **Build**: Multi-stage Dockerfile with production/development targets
- **Port**: 5050
- **Environment Variables**:
  - `PORT=5050`
  - `MONGO_URI=mongodb://root:toor@mongodb:27017/mydatabase?authSource=admin`
  - `NODE_ENV=production|development`
- **Health Check**: HTTP request to localhost:5050
- **Security**: Runs as non-root user in production

### Frontend (React/Vite)
- **Production**: Built static files served by Nginx on port 80
- **Development**: Vite dev server on port 5173 with hot reload
- **Build**: Multi-stage Dockerfile for optimized production builds
- **Health Check**: HTTP request to web server

## Environment Variables

### Backend
- `PORT`: Server port (default: 5050)
- `MONGO_URI`: MongoDB connection string
- `NODE_ENV`: Environment mode (production/development)

### Frontend (Development)
- `VITE_API_URL`: Backend API URL for development

## Networking

All services communicate through a custom Docker network:
- **Production**: `app-network`
- **Development**: `app-network-dev`

## Data Persistence

MongoDB data is persisted using Docker named volumes:
- **Production**: `mongodb_data` and `mongodb_config`
- **Development**: `mongodb_data_dev` and `mongodb_config_dev`

## Health Checks

All services include health checks:
- **MongoDB**: Database ping every 30s
- **Backend**: HTTP health check every 30s
- **Frontend**: Web server availability check every 30s

## Troubleshooting

### Check service status:
```bash
docker-compose ps
```

### View service logs:
```bash
docker-compose logs [service-name]
```

### Access service shell:
```bash
docker-compose exec backend sh
docker-compose exec mongodb mongosh
```

### Restart specific service:
```bash
docker-compose restart backend
```

### Check MongoDB connection:
```bash
docker-compose exec mongodb mongosh -u root -p toor --authenticationDatabase admin
```

## Development Workflow

1. **Start development environment:**
   ```bash
   docker-compose -f docker-compose.dev.yml up -d
   ```

2. **Make changes to your code** - changes will be reflected automatically due to volume mounts

3. **View logs in real-time:**
   ```bash
   docker-compose -f docker-compose.dev.yml logs -f
   ```

4. **Access MongoDB for debugging:**
   ```bash
   docker-compose -f docker-compose.dev.yml exec mongodb mongosh -u root -p toor --authenticationDatabase admin
   ```

## Production Deployment

For production deployment:

1. Ensure proper environment variables are set
2. Use the production docker-compose.yml
3. Consider using Docker Swarm or Kubernetes for orchestration
4. Set up proper logging and monitoring
5. Use secrets management for sensitive data
6. Configure proper backups for MongoDB data

## Security Notes

- Change default MongoDB credentials in production
- Use environment files for sensitive data
- Implement proper authentication and authorization
- Use HTTPS in production with proper SSL certificates
- Keep Docker images updated with security patches

---

# 🚀 Manual Docker Setup for MongoDB, Backend, and Frontend Services

This project contains three main services:  
- **MongoDB** for the database  
- **Backend API** (Node.js)  
- **Frontend Web App** (e.g., Vite + React/Vue)  

Instead of using `docker-compose`, this guide shows how to run each service manually using Docker commands via the terminal.

---

## 📦 Prerequisites

- Docker installed and running


---

## 1️⃣ Create Docker Volumes and Network

```bash
# Create persistent volumes
docker volume create mongodb_data
docker volume create mongodb_config

# Create a custom Docker network
docker network create app-network

```
### Start MongoDB Container

```bash
docker run -d \
  --name mongodb \
  --network app-network \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=root \
  -e MONGO_INITDB_ROOT_PASSWORD=toor \
  -e MONGO_INITDB_DATABASE=mydatabase \
  -v mongodb_data:/data/db \
  -v mongodb_config:/data/configdb \
  mongo:7-jammy
```
## 2️⃣ Build and Start Backend API
### Build Backend Image
```bash
docker build --target production -t backend-image ./backend
```
### Run Backend Container
```bash
docker run -d \
  --name backend \
  --network app-network \
  -p 5050:5050 \
  -e PORT=5050 \
  -e NODE_ENV=production \
  -e MONGO_URI='mongodb://root:toor@mongodb:27017/mydatabase?authSource=admin' \
  backend-image
```
---

# 4️⃣ Build and Start Frontend Web App

### Build Frontend Image

```bash
docker build --target production -t frontend-image \
  --build-arg VITE_API_URL=http://localhost:5050 ./frontend

```

### Run Frontend Container

```bash
docker run -d \
  --name frontend \
  --network app-network \
  -p 5173:5173 \
  frontend-image
```