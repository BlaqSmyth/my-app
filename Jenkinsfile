pipeline {
    agent {
        docker {
            image 'node:16'  // Use official Node.js image to build the app
            label 'docker'  // Use this label for Jenkins agent
            args '-v /var/run/docker.sock:/var/run/docker.sock'  // Allow Docker inside container
        }
    }

    environment {
        DOCKERHUB_CREDS = credentials('dockerhub-credentials')  // Jenkins Docker Hub credentials
        DOCKER_REPO = 'yourdockerhubusername/my-app'  // Your Docker Hub repository
        EC2_INSTANCE = 'ec2-instance-public-ip'  // Public IP of EC2 Instance 2 (deployment server)
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/BlaqSmyth/my-app.git'  // Clone the Node.js app repository
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    sh 'npm install'  // Install Node.js dependencies
                }
            }
        }

        stage('Test Application') {
            steps {
                script {
                    sh 'npm test'  // Run tests
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    docker build -t $DOCKER_REPO:$BUILD_ID .  // Build Docker image with unique tag
                    '''
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin  // Log in to Docker Hub
                        docker push $DOCKER_REPO:$BUILD_ID  // Push the Docker image to Docker Hub
                        '''
                    }
                }
            }
        }

        stage('Deploy to EC2 Instance') {
            steps {
                script {
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i /path/to/your/private-key.pem ubuntu@$EC2_INSTANCE << 'EOF'
                        docker pull $DOCKER_REPO:$BUILD_ID  // Pull the latest image from Docker Hub
                        docker stop nodejs-app || true  // Stop any running container
                        docker rm nodejs-app || true  // Remove old container
                        docker run -d --name nodejs-app -p 3000:3000 $DOCKER_REPO:$BUILD_ID  // Run the new container
                    EOF
                    '''
                }
            }
        }
    }
}
