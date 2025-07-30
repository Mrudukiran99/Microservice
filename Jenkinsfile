pipeline {
  agent any

  stages {
    stage('Deploy To Kubernetes') {
      steps {
        withKubeCredentials(kubectlCredentials: [[
          caCertificate: '',
          clusterName: 'EKS-1',
          contextName: '',
          credentialsId: 'k8-token',
          namespace: 'webapps',
          serverUrl: 'https://F96DD25419E606B64F977E5CBD3DAABA.gr7.us-east-1.eks.amazonaws.com'
        ]]) {
          sh "kubectl apply -f deployment-service.yml"
        }
      }
    }

    stage('verify Deployment') {
      steps {
        withKubeCredentials(kubectlCredentials: [[
          caCertificate: '',
          clusterName: 'EKS-1',
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
