pipeline {
  agent any

  environment {
    DOCKER_IMAGE = "mrudukiran/frontend:latest"
    DOCKER_CREDENTIALS_ID = 'docker-cred'
    K8S_CREDENTIALS_ID = 'k8-token'
    K8S_CLUSTER_NAME = 'EKS-1'
    K8S_NAMESPACE = 'webapps'
    K8S_API_SERVER = 'https://E3D018591B0D64A7661E17FB339E95D3.sk1.us-east-1.eks.amazonaws.com'
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
          usernameVariable: 'DOCKER_USERNAME',
          passwordVariable: 'DOCKER_PASSWORD'
        )]) {
          sh """
            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
            docker push ${DOCKER_IMAGE}
          """
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
          sh "kubectl get svc -n ${K8S_NAMESPACE}"
        }
      }
    }
  }
}
