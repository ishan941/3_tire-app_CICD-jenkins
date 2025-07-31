#!/bin/bash

# HPA Load Testing Script
set -e

NAMESPACE="task-app"

echo "🧪 Starting HPA Load Test..."
echo "This will generate load to test horizontal pod autoscaling"
echo ""

# Function to show current HPA status
show_hpa_status() {
    echo "📊 Current HPA Status:"
    kubectl get hpa -n $NAMESPACE
    echo ""
    echo "📦 Current Pods:"
    kubectl get pods -n $NAMESPACE -l app=task-backend
    echo ""
}

# Function to create load testing pod
create_load_test_pod() {
    echo "🚀 Creating load testing pod..."
    
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: load-tester
  namespace: $NAMESPACE
spec:
  containers:
  - name: load-tester
    image: busybox
    command: ["/bin/sh"]
    args: ["-c", "while true; do wget -q -O- http://backend:5050/ || true; done"]
  restartPolicy: Never
EOF

    echo "✅ Load testing pod created"
}

# Function to create CPU stress pod
create_cpu_stress_pod() {
    echo "🔥 Creating CPU stress pod..."
    
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cpu-stress-tester
  namespace: $NAMESPACE
spec:
  containers:
  - name: stress
    image: polinux/stress
    command: ["stress"]
    args: ["--cpu", "2", "--timeout", "300s"]
    resources:
      requests:
        cpu: "200m"
        memory: "100Mi"
      limits:
        cpu: "500m"
        memory: "200Mi"
  restartPolicy: Never
EOF

    echo "✅ CPU stress pod created"
}

# Function to generate frontend load
generate_frontend_load() {
    echo "🎨 Generating frontend load..."
    
    # Create multiple frontend load generator pods
    for i in {1..5}; do
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: frontend-load-generator-$i
  namespace: $NAMESPACE
spec:
  containers:
  - name: load-gen
    image: busybox
    command: ["/bin/sh"]
    args: ["-c", "for j in \$(seq 1 2000); do for k in \$(seq 1 20); do wget -q -O- http://frontend/ & done; wait; sleep 0.05; done"]
  restartPolicy: Never
EOF
    done
    
    echo "✅ Created 5 concurrent frontend load generators"
}

# Function to generate multiple concurrent requests
generate_load() {
    echo "⚡ Generating high load with multiple concurrent requests..."
    
    # Create multiple load generator pods
    for i in {1..5}; do
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: load-generator-$i
  namespace: $NAMESPACE
spec:
  containers:
  - name: load-gen
    image: busybox
    command: ["/bin/sh"]
    args: ["-c", "for j in \$(seq 1 1000); do for k in \$(seq 1 10); do wget -q -O- http://backend:5050/ & done; wait; sleep 0.1; done"]
  restartPolicy: Never
EOF
    done
    
    echo "✅ Created 5 concurrent load generators"
}

# Function to monitor scaling
monitor_scaling() {
    echo "👀 Monitoring HPA scaling (will check every 5 seconds for 10 minutes)..."
    echo "Press Ctrl+C to stop monitoring"
    
    for i in {1..20}; do
        echo "--- Check $i/20 ($(date)) ---"
        show_hpa_status
        echo "Waiting 5 seconds..."
        sleep 5
    done
}

# Function to cleanup
cleanup() {
    echo "🧹 Cleaning up load test resources..."
    kubectl delete pod load-tester -n $NAMESPACE --ignore-not-found=true
    kubectl delete pod cpu-stress-tester -n $NAMESPACE --ignore-not-found=true
    for i in {1..5}; do
        kubectl delete pod load-generator-$i -n $NAMESPACE --ignore-not-found=true
        kubectl delete pod frontend-load-generator-$i -n $NAMESPACE --ignore-not-found=true
    done
    echo "✅ Cleanup complete"
}

# Script usage
case "${1}" in
    "status")
        show_hpa_status
        ;;
    "light-load")
        create_load_test_pod
        echo "Light load test started. Monitor with: $0 status"
        ;;
    "cpu-stress")
        create_cpu_stress_pod
        echo "CPU stress test started. Monitor with: $0 status"
        ;;
    "frontend-load")
        generate_frontend_load
        echo "Frontend load test started. Monitor with: $0 status"
        ;;
    "heavy-load")
        generate_load
        echo "Heavy load test started. Monitor with: $0 status"
        ;;
    "monitor")
        monitor_scaling
        ;;
    "cleanup")
        cleanup
        ;;
    "full-test")
        show_hpa_status
        echo "Starting full HPA test..."
        generate_load
        sleep 5
        monitor_scaling
        ;;
    *)
        echo "🧪 HPA Load Testing Script"
        echo ""
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  status         Show current HPA and pod status"
        echo "  light-load     Start light load testing"
        echo "  cpu-stress     Start CPU stress testing"
        echo "  frontend-load  Start frontend load testing"
        echo "  heavy-load     Start heavy load testing"
        echo "  monitor        Monitor HPA scaling for 10 minutes"
        echo "  full-test      Run complete load test with monitoring"
        echo "  cleanup        Clean up all test resources"
        echo ""
        echo "Examples:"
        echo "  $0 status        # Check current status"
        echo "  $0 heavy-load    # Generate heavy load"
        echo "  $0 monitor       # Watch scaling happen"
        echo "  $0 full-test     # Run complete test"
        echo "  $0 cleanup       # Clean up after testing"
        ;;
esac
