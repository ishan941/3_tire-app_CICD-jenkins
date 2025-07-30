#!/bin/bash

# Simple 3-Tier Application Deployment Script
set -e  # Exit on any error

# Configuration
NAMESPACE="task-app"

# Build and deploy function
deploy() {
    VERSION=${1:-"latest"}
    echo "🚀 Starting deployment..."
    echo "Version: $VERSION"
    
    # Build backend
    echo "📦 Building backend..."
    cd backend
    docker build -t rohankhanal14/task-backend:$VERSION .
    cd ..
    
    # Build frontend  
    echo "📦 Building frontend..."
    cd frontend
    docker build --target production -t rohankhanal14/task-frontend:$VERSION .
    cd ..
    
    # Push images
    echo "⬆️ Pushing images..."
    docker push rohankhanal14/task-backend:$VERSION
    docker push rohankhanal14/task-frontend:$VERSION
    
    # Update manifests
    echo "📝 Updating manifests..."
    sed -i "s|task-backend:.*|task-backend:$VERSION|g" k8s/backend-dep.yml
    sed -i "s|task-frontend:.*|task-frontend:$VERSION|g" k8s/frontend-dep.yml
    
    # Deploy to Kubernetes
    echo "☸️ Deploying to Kubernetes..."
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    kubectl apply -f k8s/
    
    # Wait for pods
    echo "⏳ Waiting for pods..."
    kubectl rollout status deployment/task-backend-deployment -n $NAMESPACE
    kubectl rollout status deployment/task-frontend-deployment -n $NAMESPACE
    
    # Show status
    echo "✅ Deployment complete!"
    kubectl get pods,svc -n $NAMESPACE
}

# Script usage
case "${1}" in
    "status")
        echo "📊 Checking status..."
        kubectl get pods,svc -n $NAMESPACE
        ;;
    "clean")
        echo "🧹 Cleaning up..."
        kubectl delete namespace $NAMESPACE --ignore-not-found=true
        echo "✅ Cleanup complete"
        ;;
    *)
        deploy $1
        ;;
esac
