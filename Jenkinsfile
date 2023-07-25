pipeline {
    agent any
  
    stages {
        stage('Checkout') {
            steps {
                dir('C:\\Code\\FiberGIS_GestionWeb\\GestionWeb') {
                    git branch: 'master', url: 'https://x-token-auth:ATCTT3xFfGN0VMhtXjdy2egBgtCMCFMMueHi_EUNVlOCmcOEaRiR5CPnmpqa7F81W3z3vvGxnDUf6ApVEbwXdPlrfnVwqpse7AKUP6h5EMpMnY16g5D8vC5bz10dIi1f5rafwqj3fdkLZS_dvYtoeVU3XdjLsm0yP1Qa1oLveAAKWybfjh9u6zU=CDA97C1B@bitbucket.org/geosystems_ar/gestionweb.git'
                    script {
                        def commit_hash = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                        def commit_message = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
                        env.LAST_COMMIT_HASH = commit_hash
                        env.LAST_COMMIT_MESSAGE = commit_message
                    }                         
                }
            }
        }
        stage('Build') {
            steps {
                dir('C:\\Code\\FiberGIS_GestionWeb\\GestionWeb') {
                    // Instalar las dependencias de la aplicación utilizando npm
                    bat 'npm install'
                    // Realizar el build de la aplicación sobrescribiendo el baseHref del angular.json
                    bat 'npm run build -- --configuration production --base-href=""'
                    // Realizar el build de la aplicación utilizando el comando npm run build:component
                    //bat 'npm run build:component'
                }
            }
        }    
        stage('SonarQube Analysis') {
            steps {
                dir('C:\\Code\\FiberGIS_GestionWeb\\GestionWeb') {
                    withSonarQubeEnv('sonarqubeserver') {
                        script {
                            def scannerHome = tool 'sonarscanner'
                            withSonarQubeEnv(credentialsId: 'sonarqube') {
                                bat "${scannerHome}\\bin\\sonar-scanner.bat -Dsonar.projectKey=FiberGIS_GestionWeb -Dsonar.sources=src -Dsonar.exclusions=**/node_modules/**"
                            }
                        }
                    }
                }
            }
        }       
        stage('Transfer files to remote server') {
            steps {
                sshagent(['SSH_Server_135_geouser']) {
                    sh 'scp C:/Code/FiberGIS_GestionWeb/Dockerfile geouser@192.168.1.135:/usr/src/app/fibergis_gestionweb/'
                    sh 'scp C:/Code/FiberGIS_GestionWeb/nginx.conf geouser@192.168.1.135:/usr/src/app/fibergis_gestionweb/'
                    sh 'scp -r C:/Code/FiberGIS_GestionWeb/GestionWeb/dist geouser@192.168.1.135:/usr/src/app/fibergis_gestionweb/'
                }
            }
        }        
        stage('Build Docker image') {
            steps {
                sshagent(['SSH_Server_135_geouser']) {
                    sh '''
                        ssh geouser@192.168.1.135 "
                            cd /usr/src/app/fibergis_GestionWeb && 
                            if docker ps -a | grep fggestionweb >/dev/null 2>&1; then docker stop fggestionweb && 
                            docker rm fggestionweb; fi && 
                            docker image rm -f fggestionweb:qa || true && 
                            docker build -t fggestionweb:qa --no-cache /usr/src/app/fibergis_gestionweb
                        "
                    '''             
                }
            }
        }      
        stage('Run Docker container') {
            steps {
                sshagent(['SSH_Server_135_geouser']) {
                    sh '''
                        ssh geouser@192.168.1.135 "
                            docker run -d --restart=always -p 82:82 --name fggestionweb fggestionweb:qa
                        "
                    '''
                }
            }
        } 
    } 
    /*post {
        success {
            emailext body: "La subida de FiberGIS_GestionWeb se ha completado con exito.\n\n" +
                           "Ultimo mensaje de commit: ${env.LAST_COMMIT_MESSAGE}\n\n" +
                           "Commit Id: ${env.LAST_COMMIT_HASH}.\n\n" +
                           "GestionWeb\n" +
                           "https://web.fibergis.com.ar/qa/Catalogo/\n\n" +
                           "Job Name: ${env.JOB_NAME}\n" +
                           "Build: ${env.BUILD_NUMBER}\n" +
                           "Console output: ${env.BUILD_URL}",  
                     subject: 'FiberGIS_GestionWeb - Subida Exitosa',
                     to: 'Raul.Anchorena@geosystems.com.ar;Agustin.David@geosystems.com.ar'
        }
        failure {
            emailext body: "La subida de FiberGIS_GestionWeb ha fallado.\n\n" +
                           "Job Name: ${env.JOB_NAME}\n" +
                           "Build: ${env.BUILD_NUMBER}\n" +
                           "Console output: ${env.BUILD_URL}", 
                     subject: 'FiberGIS_GestionWeb - La subida ha Fallado - ERROR',
                     to: 'Raul.Anchorena@geosystems.com.ar;Agustin.David@geosystems.com.ar'
        }
    }*/
}

