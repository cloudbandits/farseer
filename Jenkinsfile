pipeline {
  agent any

  environment {
    DOCKER_CREDS_USR = credentials('DOCKER_CREDS_USR')
    DOCKER_CREDS_PSW = credentials('DOCKER_CREDS_PSW')
    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_KEY')
    API_KEY = credentials('API_KEY')
    SONAR_SCANNER_HOME = tool 'SonarQube Scanner' // Name configured in Jenkins global tools
  }

    stages {
        stage('Build') {
            steps {
                script {
                    // For Linux/Mac
                    sh './CICD_Scripts/frontend.sh'
                    sh './CICD_Scripts/backend.sh'

                }
            }
        }
    }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') { // 'SonarQube' is the name configured in Jenkins
                    sh """
                    ${env.SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=your_project_key \
                        -Dsonar.sources=src \
                        -Dsonar.host.url=http://<sonarqube-server-ip>:9000 \
                        -Dsonar.login=your_sonar_token
                    """
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') { // Adjust timeout as necessary
                    waitForQualityGate abortPipeline: true
                }
            }
        }

      stage('Cleanup') {
        agent { label 'build-node' }
        steps {
          sh '''
            docker system prune -f
            git clean -ffdx -e "*.tfstate*" -e ".terraform/*"
          '''
        }
      }

    stage('Build & Push Images') {
        agent { label 'build-node' }
        steps {
            // Log in to Docker Hub
            sh 'echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin'
            
            // Inject API Key
            withCredentials([string(credentialsId: 'MY_API_KEY', variable: 'API_KEY')]) {
                // Build and push backend
                sh '''
                  docker build --build-arg API_KEY=${API_KEY} -t ${DOCKER_CREDS_USR}/<backend_name>:latest -f Dockerfile.backend .
                  docker push ${DOCKER_CREDS_USR}/<backend_name>:latest
                '''
                
                // Build and push frontend
                sh '''
                  docker build -t ${DOCKER_CREDS_USR}/<frontend_name>:latest -f Dockerfile.frontend .
                  docker push ${DOCKER_CREDS_USR}/<frontend_name>:latest
                '''
            }
        }
    }

stage('Deploy') {
    steps {
        script {
            if (env.BRANCH_NAME == 'production') {
                echo "Deploying to Production Environment"
                dir('terraform/production') { // Navigate to the production environment directory
                    sh '''
                      echo "Current working directory:"
                      pwd
                      terraform init
                      terraform apply -auto-approve \
                        -var="dockerhub_username=${DOCKER_CREDS_USR}" \
                        -var="dockerhub_password=${DOCKER_CREDS_PSW}"

          '''
                }
            } else if (env.BRANCH_NAME == 'qa') {
                echo "Deploying to Testing Environment"
                dir('terraform/qa') { // Navigate to the qa environment directory
                    sh '''
                      echo "Current working directory:"
                      pwd
                      terraform init
                      terraform apply -auto-approve \
                        -var="dockerhub_username=${DOCKER_CREDS_USR}" \
                        -var="dockerhub_password=${DOCKER_CREDS_PSW}"

          '''
                }
            } else if (env.BRANCH_NAME == 'develop') {
                echo "Deploying to Staging Environment"
                dir('terraform/develop') { // Navigate to the staging environment directory
                    sh '''
                      echo "Current working directory:"
                      pwd
                      terraform init
                      terraform apply -auto-approve \
                        -var="dockerhub_username=${DOCKER_CREDS_USR}" \
                        -var="dockerhub_password=${DOCKER_CREDS_PSW}"

          '''
                }
            } else if (env.BRANCH_NAME.startsWith('feature/')) {
                echo "Skipping deployment for feature branch: ${env.BRANCH_NAME}"
            } else {
                error("Unknown branch: ${env.BRANCH_NAME}")
            }
        }
    }
}

  

    // Add a Cleanup Stage Here
    stage('post stage') {
      agent { label 'build-node' } // Specify your preferred agent here
      steps {
        sh '''
          docker logout
          docker system prune -f
        '''
      }
    }
    }

    // stage('Destroy') {
    //   agent { label 'build-node' }
    //   steps {
    //     dir('Terraform') {
    //       sh ''' 
    //         terraform destroy -auto-approve \
    //           -var="dockerhub_username=${DOCKER_CREDS_USR}" \
    //           -var="dockerhub_password=${DOCKER_CREDS_PSW}"
    //       '''
    //     }
    //   }
    // }
  





