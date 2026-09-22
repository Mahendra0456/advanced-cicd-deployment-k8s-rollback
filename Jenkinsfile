pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "mahendra46/week9-app"
        DOCKER_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code from GitHub...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building application...'
                sh '''
                    cd app
                    test -f index.html
                    echo "Application build validation successful."
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Running automated tests...'
                sh '''
                    cd app
                    chmod +x test.sh
                    ./test.sh
                '''
            }
        }

        stage('Package') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    docker build \
                    -t ${DOCKER_IMAGE}:${IMAGE_TAG} \
                    ./app
                '''
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'

                sh '''
                    echo "$DOCKER_CREDENTIALS_PSW" | \
                    docker login -u "$DOCKER_CREDENTIALS_USR" \
                    --password-stdin

                    docker push ${DOCKER_IMAGE}:${IMAGE_TAG}

                    docker logout
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application to Kubernetes...'

                sh '''
                    sed "s#DOCKERHUB_USERNAME/week9-app:BUILD_NUMBER#${DOCKER_IMAGE}:${IMAGE_TAG}#" \
                    k8s/deployment.yaml > /tmp/week9-deployment.yaml

                    kubectl apply -f /tmp/week9-deployment.yaml
                    kubectl apply -f k8s/service.yaml
                '''
            }
        }

        stage('Verify') {
            steps {
                echo 'Verifying Kubernetes deployment...'

                sh '''
                    kubectl rollout status deployment/week9-app --timeout=180s
                    kubectl get deployment week9-app
                    kubectl get pods -l app=week9-app
                    kubectl get service week9-app-service
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
        }

        failure {
            echo 'CI/CD pipeline failed. Check the Jenkins console output.'
        }
    }
}
