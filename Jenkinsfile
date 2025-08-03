pipeline {
  agent any

  environment {
    DOCKER_IMAGE = "mrudukiran/frontend:latest"
    DOCKER_CREDENTIALS_ID = 'docker-cred'  // Jenkins Docker Hub credentials ID
    K8S_CREDENTIALS_ID = 'k8-token'       // Jenkins Kubernetes token credentials ID
    K8S_CLUSTER_NAME = 'EKS-1'
    K8S_NAMESPACE = 'webapps'
    K8S_API_SERVER = 'https://555ADC334545656A0F62A84D584110B5.gr7.us-east-1.eks.amazonaws.com'
  }

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          docker.build("${DOCKER_IMAGE}")
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'docker-cred',
          usernameVariable: 'DOCKER_USERNAME',
          passwordVariable: 'DOCKER_PASSWORD'
        )]) {
          sh '''
            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
            docker push ${DOCKER_IMAGE}
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        withKubeCredentials(kubectlCredentials: [[
          caCertificate: '',
          clusterName: "${K8S_CLUSTER_NAME}",
          contextName: '',
          credentialsId: "${K8S_CREDENTIALS_ID}",
          namespace: "${K8S_NAMESPACE}",
          serverUrl: "${K8S_API_SERVER}"
        ]]) {
          sh "kubectl apply -f deployment-service.yml -n ${K8S_NAMESPACE}"
        }
      }
    }

    stage('Verify Deployment') {
      steps {
        withKubeCredentials(kubectlCredentials: [[
          caCertificate: '',
          clusterName: "${K8S_CLUSTER_NAME}",
          contextName: '',
          credentialsId: "${K8S_CREDENTIALS_ID}",
          namespace: "${K8S_NAMESPACE}",
          serverUrl: "${K8S_API_SERVER}"
        ]]) {
          sh "kubectl get pods -n ${K8S_NAMESPACE}"
          sh "kubectl get svc -n ${K8S_NAMESPACE}"
        }
      }
    }
  }
}
