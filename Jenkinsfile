pipeline {
  agent any

  environment {
    DOCKER_CREDS_USR = credentials('DOCKER_CREDS_USR')
    DOCKER_CREDS_PSW = credentials('DOCKER_CREDS_PSW')
    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_KEY')
    //DEV_KEY =credentials('dev_key')
    XAI_KEY = credentials('XAI_KEY')
  }

    stages {
        // stage('Build') {
        //     steps {
        //         script {
        //             sh '''
        //             chmod +x ./CICD_Scripts/frontend.sh
        //             ./CICD_Scripts/frontend.sh
        //             chmod +x ./CICD_Scripts/backend.sh
        //             ./CICD_Scripts/backend.sh
        //             '''

        //               }
        //           } 
        //       }
    

        // stage ('Sec-Check: OWASP') {
        //     environment {
        //         NVD_APIKEY = credentials("NVD-ApiKey")
        //     }
        //     steps {
        //         dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey ${NVD_APIKEY}', odcInstallation: 'DP-Check'
        //         dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        //     }
        // }



      stage('Cleanup') {
        agent { label 'build-node' }
        steps {
          sh '''
            docker system prune -f
            git clean -ffdx -e "*.tfstate*" -e ".terraform/*"
          '''
        }
      }

    // stage('Build & Push Images') {
    //     agent { label 'build-node' }
    //     steps {
    //         // Log in to Docker Hub
    //         sh 'echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin'
            
    //         // Inject API Key
    //         withCredentials([string(credentialsId: 'XAI_KEY', variable: 'XAI_KEY')]) {
    //             // Build and push backend
    //             sh '''
    //               echo "Current directory: $(pwd)"
    //               docker build --build-arg XAI_KEY=${XAI_KEY} -t ${DOCKER_CREDS_USR}/farseer_back:latest -f ./docker/back.Dockerfile .
    //               docker push ${DOCKER_CREDS_USR}/farseer_back:latest
    //             '''
                
    //             // Build and push frontend
    //             sh '''
    //               docker build -t ${DOCKER_CREDS_USR}/farseer_front:latest -f ./docker/front.Dockerfile .
    //               docker push ${DOCKER_CREDS_USR}/farseer_front:latest
    //             '''
    //         }
    //     }
    // }
                              // -var="dockerhub_username=${DOCKER_CREDS_USR}" \
                          //   -var="dockerhub_password=${DOCKER_CREDS_PSW}"

stage('Deploy') {
    agent { label 'build-node' }
    steps {
        script {
            def stacking_folder = ""
            def env_folder = ""    

            // Determine the stacking folder (green/blue)
            if (env.BRANCH_NAME.endsWith('_green')) {
                stacking_folder = 'green'
            } else if (env.BRANCH_NAME.endsWith('_blue')) {
                stacking_folder = 'blue'
            } else {
                echo "No matching branch suffix. Skipping deployment."
                error("Unknown branch suffix in: ${env.BRANCH_NAME}")
            }  

            // Determine the environment folder (Dev, QA, etc.)
            if (env.BRANCH_NAME.startsWith('feature/')) {
                env_folder = "sb" 
            } else if (env.BRANCH_NAME.startsWith('develop')) {
                env_folder = "Dev"       
            } else if (env.BRANCH_NAME.startsWith('qa')) {
                env_folder = "QA"
            } else if (env.BRANCH_NAME.startsWith('prod')) {
                env_folder = "Production"
            } else {
                echo "No deployment for branch: ${env.BRANCH_NAME}"
                error("Unknown branch prefix in: ${env.BRANCH_NAME}")
            }     

            echo "Deploying to ${stacking_folder}/${env_folder} environment"

            // Navigate to the appropriate Terraform folder
            dir("Terraform/${stacking_folder}/${env_folder}") {
                sh '''
                    echo "Current working directory:"
                    pwd
                    terraform init
                    terraform apply -auto-approve
                '''
            }

            echo "Navigating back to the root directory"
            dir('.') {
                // Validate the script path and execute
                def script_path = "k8s/${stacking_folder}/${env_folder}/${env_folder}_k8s_setup.sh"
                echo "Checking script at path: ${script_path}"
                sh '''
                  if [ ! -f ${script_path} ]; then
                    echo "Error: Script ${script_path} not found."
                    exit 1
                  fi

                  # Ensure script is executable
                  chmod +x ${script_path}

                  # Execute the script, passing the XAI_KEY ENV Variable
                  ${script_path} $XAI_KEY
                '''
            }
        }
    }
}

  

    // Add a Cleanup Stage Here
    // stage('logout') {
    //   agent { label 'build-node' } // Specify your preferred agent here
    //   steps {
    //     sh '''
    //       docker logout
    //       docker system prune -f
    //     '''
    //   }
    // }



    // stage('Destroy') {
    //   agent { label 'build-node' }
    //   steps {
    //     dir('Terraform/Dev') {
    //       sh ''' 
    //         terraform destroy -auto-approve
    //       '''
    //     }
    //   }
    // }
    }
        }
  

