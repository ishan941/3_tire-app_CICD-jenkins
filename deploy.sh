#!/bin/bash

# Simple 3-Tier Application Deployment Script
set -e  # Exit on any error

# Configuration
NAMESPACE="task-app"

# Build and deploy function
deploy() {
    echo "🚀 Starting deployment..."

    # Deploy to Kubernetes
    echo "☸️ Deploying to Kubernetes..."
    kubectl apply -f k8s/ns.yml
    kubectl apply -f k8s/secrets.yml
    kubectl apply -f k8s/backend-dep.yml
    kubectl apply -f k8s/backend-svc.yml
    kubectl apply -f k8s/frontend-dep.yml
    kubectl apply -f k8s/frontend-svc.yml
    kubectl apply -f k8s/ingress.yml
    
    # Show status

    echo "Deployment complete!"
    kubectl get all -n $NAMESPACE
}


# Port forwarding function
port_forward() {
    echo "Setting up port forwarding..."
    echo "Frontend will be available at: http://localhost:3000"
    echo "Backend API will be available at: http://localhost:5050"
    echo "Press Ctrl+C to stop port forwarding"
    
    # Start port forwarding for frontend and backend
    kubectl port-forward -n $NAMESPACE svc/frontend 3000:80 &
    kubectl port-forward -n $NAMESPACE svc/backend 5050:5050 &
    
}

# Script usage
case "${1}" in
    "status")
        echo "📊 Checking status..."
        kubectl get all -n $NAMESPACE
        ;;
    "clean")
        echo "🧹 Cleaning up..."
        kubectl delete namespace $NAMESPACE --ignore-not-found=true
        echo "✅ Cleanup complete"
        ;;
    "port-forward" | "pf")
        port_forward
        ;;
    *)
        deploy
        ;;
esac
