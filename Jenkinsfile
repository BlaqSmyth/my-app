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

                git branch: 'master',
                    credentialsId: 'GitHub-ID',
                    url: 'https://github.com/BlaqSmyth/my-app.git'
            }
        }

        stage('View Project Files') {
            steps {
                echo 'Showing files in Jenkins workspace...'

                sh '''
                    echo "Current working directory:"
                    pwd

                    echo "Root project files:"
                    ls -la

                    echo "Application files:"
                    ls -la app

                    echo "Searching for package.json:"
                    find . -name package.json -type f
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'

                dir('app') {
                    sh '''
                        echo "Installing dependencies from:"
                        pwd

                        npm install
                    '''
                }
            }
        }

        stage('Validate Application') {
            steps {
                echo 'Validating Node.js application...'

                dir('app') {
                    sh '''
                        echo "Checking server.js syntax..."

                        node --check server.js

                        echo "Application syntax validation completed successfully."
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'

                sh '''
                    echo "Docker version:"
                    docker --version

                    echo "Building image: $IMAGE_NAME"

                    docker build -t $IMAGE_NAME .

                    echo "Creating latest tag..."

                    docker tag $IMAGE_NAME $LATEST_IMAGE

                    echo "Docker images:"
                    docker images
                '''
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                echo 'Logging in to Amazon ECR...'

                sh '''
                    echo "AWS CLI version:"
                    aws --version

                    echo "AWS identity:"
                    aws sts get-caller-identity

                    aws ecr get-login-password \
                        --region $AWS_REGION | \
                    docker login \
                        --username AWS \
                        --password-stdin $ECR_REGISTRY
                '''
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                echo 'Pushing Docker images to Amazon ECR...'

                sh '''
                    echo "Pushing build image:"
                    echo "$IMAGE_NAME"

                    docker push $IMAGE_NAME

                    echo "Pushing latest image:"
                    echo "$LATEST_IMAGE"

                    docker push $LATEST_IMAGE
                '''
            }
        }

        stage('Verify Image in ECR') {
            steps {
                echo 'Verifying images in Amazon ECR...'

                sh '''
                    aws ecr describe-images \
                        --repository-name $ECR_REPOSITORY \
                        --region $AWS_REGION \
                        --query "imageDetails[*].{Tags:imageTags,PushedAt:imagePushedAt,Digest:imageDigest}" \
                        --output table
                '''
            }
        }
    }

    post {

        success {
            echo '========================================='
            echo 'PIPELINE COMPLETED SUCCESSFULLY'
            echo '========================================='
            echo "Docker image pushed: ${IMAGE_NAME}"
            echo "Latest image: ${LATEST_IMAGE}"
        }

        failure {
            echo '========================================='
            echo 'PIPELINE FAILED'
            echo '========================================='
            echo 'Check the Jenkins console output for the failed stage.'
        }

        always {
            echo 'Cleaning unused Docker images...'

            sh '''
                docker image prune -f || true
            '''
        }
    }
}
