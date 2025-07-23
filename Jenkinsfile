pipeline {
    agent any

    stages {
        stage('Deploy To Kubernetes') {
            steps {
                withCredentials([string(credentialsId: 'k8-token', variable: 'KUBECONFIG_CONTENT')]) {
                    sh '''
                        echo "$KUBECONFIG_CONTENT" > kubeconfig
                        export KUBECONFIG=$PWD/kubeconfig
                        kubectl apply -f deployment-service.yml
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([string(credentialsId: 'k8-token', variable: 'KUBECONFIG_CONTENT')]) {
                    sh '''
                        echo "$KUBECONFIG_CONTENT" > kubeconfig
                        export KUBECONFIG=$PWD/kubeconfig
                        kubectl get svc -n webapps
                    '''
                }
            }
        }
    }
}


