pipeline {
  agent any

  environment {
    DOCKER_REGISTRY = "mrudukiran"
    K8S_NAMESPACE = "webapps"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/Mrudukiran99/Microservice.git', branch: 'main', credentialsId: 'git-cred'
      }
    }

    stage('Build and Push Images') {
      steps {
        script {
          // List of microservices (folder names + main js filename)
          def services = [
            'adservice',
            'checkoutservice',
            'currencyservice',
            'cartservice',
            'emailservice',
            'frontend',
            'paymentservice',
            'productcatalogservice',
            'recommendationservice',
            'shippingservice'
          ]

          for (service in services) {
            dir(service) {
              // Update Dockerfile CMD to run correct js file
              sh """
                sed -i 's/^CMD.*/CMD ["node", "${service}.js"]/' Dockerfile
                docker build --no-cache -t ${DOCKER_REGISTRY}/${service}:latest .
                docker push ${DOCKER_REGISTRY}/${service}:latest
              """
            }
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        // Apply Kubernetes manifests and rollout restart deployments
        sh "kubectl apply -f deployment-service.yml -n ${K8S_NAMESPACE}"

        script {
          def services = [
            'adservice',
            'checkoutservice',
            'currencyservice',
            'cartservice',
            'emailservice',
            'frontend',
            'paymentservice',
            'productcatalogservice',
            'recommendationservice',
            'shippingservice'
          ]
          for (service in services) {
            sh "kubectl rollout restart deployment ${service} -n ${K8S_NAMESPACE}"
          }
        }
      }
    }

    stage('Verify Deployment') {
      steps {
        sh "kubectl get pods -n ${K8S_NAMESPACE}"
      }
    }
  }
}
