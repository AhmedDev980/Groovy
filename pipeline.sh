# Write an apache groovy script to create a pipeline in jenkins to create nginx server, having availed images from docker hub
pipeline {
    agent any

    environment {
        // Define the Nginx Docker image from Docker Hub
        DOCKER_IMAGE = 'nginx:latest'
        CONTAINER_NAME = 'nginx-server'
        EXPOSED_PORT = '8080'
    }

    stages {
        stage('Pull Docker Image') {
            steps {
                script {
                    // Pull the Nginx image from Docker Hub
                    echo 'Pulling Nginx image from Docker Hub...'
                    sh "docker pull ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Run Nginx Container') {
            steps {
                script {
                    // Run the Nginx container on the defined port
                    echo 'Running Nginx container...'
                    sh """
                    docker run -d --name ${CONTAINER_NAME} -p ${EXPOSED_PORT}:80 ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Verify Nginx Server') {
            steps {
                script {
                    // Verify if the Nginx server is running and accessible
                    echo 'Verifying Nginx server...'
                    sh """
                    curl -I http://localhost:${EXPOSED_PORT} || exit 1
                    """
                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    // Stop and remove the Docker container after the test
                    echo 'Cleaning up Nginx container...'
                    sh """
                    docker stop ${CONTAINER_NAME}
                    docker rm ${CONTAINER_NAME}
                    """
                }
            }
        }
    }

    post {
        always {
            // Clean up any residual Docker resources if the pipeline fails
            echo 'Post pipeline cleanup...'
            sh 'docker system prune -f || true'
        }
    }
}
