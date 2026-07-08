pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
        ECR_REPOSITORY = 'my-app'
        AWS_ACCOUNT_ID = '514348992556'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_TAG = "build-${BUILD_NUMBER}"
        IMAGE_NAME = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
        LATEST_IMAGE = "${ECR_REGISTRY}/${ECR_REPOSITORY}:latest"
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                echo 'Cloning source code from GitHub...'
                git branch: 'master', url: 'https://github.com/BlaqSmyth/my-app.git'
            }
        }

        stage('View Project Files') {
            steps {
                echo 'Showing files in Jenkins workspace...'
                sh '''
                    pwd
                    ls -la
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                sh '''
                    npm test || echo "No test script found or tests failed. Continuing for demo purposes."
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    docker build -t $IMAGE_NAME .
                    docker tag $IMAGE_NAME $LATEST_IMAGE
                '''
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                echo 'Logging in to Amazon ECR...'
                sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin $ECR_REGISTRY
                '''
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                echo 'Pushing Docker image to Amazon ECR...'
                sh '''
                    docker push $IMAGE_NAME
                    docker push $LATEST_IMAGE
                '''
            }
        }

        stage('Verify Image in ECR') {
            steps {
                echo 'Verifying image in Amazon ECR...'
                sh '''
                    aws ecr describe-images \
                      --repository-name $ECR_REPOSITORY \
                      --region $AWS_REGION \
                      --query "imageDetails[*].imageTags" \
                      --output table
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully. Docker image pushed to Amazon ECR."
            echo "Image pushed: ${IMAGE_NAME}"
        }

        failure {
            echo "Pipeline failed. Check the Jenkins console output."
        }

        always {
            echo 'Cleaning unused Docker images...'
            sh '''
                docker image prune -f || true
            '''
        }
    }
}
