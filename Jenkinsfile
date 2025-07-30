pipeline {
  agent any

  environment {
    DOCKER_IMAGE = "mrudukiran/frontend:latest"
    DOCKER_CREDENTIALS_ID = 'docker-hub-creds'  // Replace with your Jenkins Docker credentials ID
  }

  stages {
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
          credentialsId: "${DOCKER_CREDENTIALS_ID}",
          passwordVariable: 'DOCKER_PASSWORD',
          usernameVariable: 'DOCKER_USERNAME'
        )]) {
          sh """
            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
            docker push ${DOCKER_IMAGE}
          """
        }
      }
    }

    stage('Deploy To Kubernetes') {
      steps {
        withKubeCredentials(kubectlCredentials: [[
          caCertificate: '',
          clusterName: 'EKS',
          contextName: '',
          credentialsId: 'k8-token',
          namespace: 'webapps',
          serverUrl: 'https://F96DD25419E606B64F977E5CBD3DAABA.gr7.us-east-1.eks.amazonaws.com'
        ]]) {
          sh "kubectl apply -f deployment-service.yml"
        }
      }
    }

    stage('Verify Deployment') {
      steps {
        withKubeCredentials(kubectlCredentials: [[
          caCertificate: '',
          clusterName: 'EKS',
          contextName: '',
          credentialsId: 'k8-token',
          namespace: 'webapps',
          serverUrl: 'https://F96DD25419E606B64F977E5CBD3DAABA.gr7.us-east-1.eks.amazonaws.com'
        ]]) {
          sh "kubectl get svc -n webapps"
        }
      }
    }
  }
}
