#!/bin/bash

echo "Validating Kubernetes deployment file..."

# Check if deployment file exists
if [ ! -f "deployment-service.yml" ]; then
    echo "Error: deployment-service.yml not found!"
    exit 1
fi

# Basic YAML syntax validation
echo "Checking YAML syntax..."
if command -v python3 >/dev/null 2>&1; then
    python3 -c "import yaml; yaml.safe_load(open('deployment-service.yml'))" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ YAML syntax is valid"
    else
        echo "✗ YAML syntax error detected"
        exit 1
    fi
else
    echo "Python3 not available, skipping YAML syntax check"
fi

# Check for required Kubernetes fields
echo "Checking for required Kubernetes fields..."
required_fields=("apiVersion" "kind" "metadata" "spec")
for field in "${required_fields[@]}"; do
    if grep -q "^$field:" deployment-service.yml; then
        echo "✓ Found required field: $field"
    else
        echo "⚠ Warning: Required field '$field' might be missing"
    fi
done

# Check for common issues
echo "Checking for common deployment issues..."

# Check if all images are specified
if grep -q "image:.*latest" deployment-service.yml; then
    echo "✓ Found image specifications"
else
    echo "⚠ Warning: No images with 'latest' tag found"
fi

# Check for resource specifications
if grep -q "resources:" deployment-service.yml; then
    echo "✓ Found resource specifications"
else
    echo "⚠ Warning: No resource limits/requests specified"
fi

echo "Validation completed!"