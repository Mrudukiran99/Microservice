pipeline {
  agent any

  environment {
    DOCKER_REGISTRY = "mrudukiran"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/Mrudukiran99/Microservice.git', credentialsId: 'git-cred', branch: 'main'
      }
    }

    stage('Build and Push Images') {
      steps {
        script {
          def services = ['adservice', 'checkoutservice', 'currencyservice', 'cartservice', 'emailservice', 'frontend', 'paymentservice', 'productcatalogservice', 'recommendationservice', 'shippingservice', 'loadgenerator']

          for (service in services) {
            echo "Building and pushing image for ${service}"
            sh """
              sed -i 's/^CMD.*/CMD ["node", "${service}.js"]/' Dockerfile
              docker build -t ${DOCKER_REGISTRY}/${service}:latest .
              docker push ${DOCKER_REGISTRY}/${service}:latest
            """
          }
        }
      }
    }

    stage('Validate Deployment') {
      steps {
        sh '''
          chmod +x validate-k8s.sh
          ./validate-k8s.sh
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        withKubeConfig(credentialsId: 'k8-token') {
          sh '''
            echo "Current directory: $(pwd)"
            echo "List files in workspace:"
            ls -l
            echo "Show first 20 lines of deployment-service.yml:"
            head -20 deployment-service.yml
            echo "Checking kubectl connection..."
            kubectl cluster-info
            echo "Checking if namespace webapps exists..."
            kubectl get namespace webapps || kubectl create namespace webapps
            echo "Applying deployment-service.yml to namespace webapps"
            kubectl apply -f deployment-service.yml -n webapps --validate=false
            echo "Waiting for deployments to be ready..."
            kubectl wait --for=condition=available --timeout=300s deployment --all -n webapps || echo "Some deployments may still be starting up"
          '''
        }
      }
    }

    stage('Verify Deployment') {
      steps {
        withKubeConfig(credentialsId: 'k8-token') {
          sh '''
            echo "Checking deployment status..."
            kubectl get deployments -n webapps
            echo "Checking pods status..."
            kubectl get pods -n webapps
            echo "Checking services..."
            kubectl get svc -n webapps
            echo "Checking for any failed pods..."
            kubectl get pods -n webapps --field-selector=status.phase=Failed
          '''
        }
      }
    }
  }
}
