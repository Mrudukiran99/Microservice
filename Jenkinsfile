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

    stage('Deploy to Kubernetes') {
      steps {
        withKubeConfig(credentialsId: 'k8-token') {
          sh '''
            echo "Current directory: $(pwd)"
            echo "List files in workspace:"
            ls -l
            echo "Show first 20 lines of deployment-service.yml:"
            head -20 deployment-service.yml
            echo "Applying deployment-service.yml to namespace webapps"
            kubectl apply -f deployment-service.yml -n webapps
          '''
        }
      }
    }

    stage('Verify Deployment') {
      steps {
        withKubeConfig(credentialsId: 'k8-token') {
          sh 'kubectl get pods -n webapps'
          sh 'kubectl get svc -n webapps'
        }
      }
    }
  }
}
