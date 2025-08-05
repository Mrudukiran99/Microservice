#!/bin/bash

set -e

echo "🚀 Kubernetes Microservices Deployment Script"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please don't run this script as root. It will use sudo when needed."
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Check prerequisites
print_status "Checking prerequisites..."

# Check if kubectl is installed
if ! command_exists kubectl; then
    print_status "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    print_status "kubectl is already installed"
fi

# Check if Docker is installed and running
if ! command_exists docker; then
    print_status "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo usermod -aG docker $USER
    print_warning "Docker installed. You may need to log out and back in for group changes to take effect."
else
    print_status "Docker is already installed"
fi

# Try to start Docker if it's not running
if ! docker info >/dev/null 2>&1; then
    print_status "Attempting to start Docker..."
    
    # Try different methods to start Docker
    if command_exists systemctl; then
        sudo systemctl start docker || print_warning "Failed to start Docker with systemctl"
    elif command_exists service; then
        sudo service docker start || print_warning "Failed to start Docker with service"
    else
        # Try to start dockerd manually
        print_status "Starting Docker daemon manually..."
        sudo dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 &
        sleep 10
    fi
    
    # Give Docker some time to start
    sleep 5
    
    # Check if Docker is now running
    if ! docker info >/dev/null 2>&1; then
        print_error "Could not start Docker. Please start Docker manually and run this script again."
        print_error "You may need to:"
        print_error "1. Start Docker service: sudo systemctl start docker"
        print_error "2. Add your user to docker group: sudo usermod -aG docker \$USER"
        print_error "3. Log out and back in, then run this script again"
        exit 1
    fi
fi

print_status "Docker is running"

# Check if kind is installed
if ! command_exists kind; then
    print_status "Installing kind..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
else
    print_status "kind is already installed"
fi

# Step 2: Create kind cluster
print_status "Creating kind cluster..."
CLUSTER_NAME="microservices"

# Check if cluster already exists
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    print_warning "Cluster '${CLUSTER_NAME}' already exists. Deleting and recreating..."
    kind delete cluster --name ${CLUSTER_NAME}
fi

# Create the cluster
kind create cluster --name ${CLUSTER_NAME} --wait 300s

# Verify cluster is ready
print_status "Verifying cluster connectivity..."
kubectl cluster-info --context kind-${CLUSTER_NAME}

if [ $? -ne 0 ]; then
    print_error "Failed to connect to the cluster"
    exit 1
fi

# Step 3: Create namespace
print_status "Creating 'webapps' namespace..."
kubectl create namespace webapps --context kind-${CLUSTER_NAME} || print_warning "Namespace might already exist"

# Step 4: Deploy the application
print_status "Deploying microservices application..."

if [ ! -f "deployment-service.yml" ]; then
    print_error "deployment-service.yml not found in current directory"
    exit 1
fi

# Apply the deployment
kubectl apply -f deployment-service.yml -n webapps --context kind-${CLUSTER_NAME}

if [ $? -eq 0 ]; then
    print_status "Application deployed successfully!"
else
    print_error "Failed to deploy application"
    exit 1
fi

# Step 5: Wait for deployments to be ready
print_status "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment --all -n webapps --context kind-${CLUSTER_NAME}

# Step 6: Show deployment status
print_status "Deployment Status:"
echo "=================="
kubectl get all -n webapps --context kind-${CLUSTER_NAME}

# Step 7: Port forwarding for frontend access
print_status "Setting up port forwarding for frontend access..."
echo ""
print_status "To access the application:"
echo "1. Run: kubectl port-forward service/frontend 8080:80 -n webapps --context kind-${CLUSTER_NAME}"
echo "2. Open your browser to: http://localhost:8080"
echo ""
print_status "To access with LoadBalancer (if supported):"
echo "kubectl get service frontend-external -n webapps --context kind-${CLUSTER_NAME}"
echo ""

# Step 8: Useful commands
print_status "Useful commands for monitoring:"
echo "================================"
echo "# View all resources:"
echo "kubectl get all -n webapps --context kind-${CLUSTER_NAME}"
echo ""
echo "# Check pod logs:"
echo "kubectl logs <pod-name> -n webapps --context kind-${CLUSTER_NAME}"
echo ""
echo "# Describe a resource:"
echo "kubectl describe <resource-type> <resource-name> -n webapps --context kind-${CLUSTER_NAME}"
echo ""
echo "# Delete the cluster when done:"
echo "kind delete cluster --name ${CLUSTER_NAME}"
echo ""

print_status "🎉 Deployment completed successfully!"
print_status "Your microservices application is now running in the kind cluster."