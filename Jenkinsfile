pipeline { 
    agent any
    stages {
        stage ('Start Time') {
            steps {
                sh '''
                    date
                ''' 
            }
        }
        stage ('Initialize - GitHub') {
            steps {
                sh '''
                    export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-arm64"
                    export PATH=$JAVA_HOME/bin:$PATH
                    export M2_HOME="/usr/share/maven"
                    export PATH=$M2_HOME/bin:$PATH
                    echo "JAVA_HOME = $JAVA_HOME"
                    echo "M2_HOME = $M2_HOME"
                ''' 
            }
        }
        stage('SCA - TruffleHog') { 
            steps { 
               sh '''
               trufflehog --version
               trufflehog git https://github.com/iankesh/ankesh-project --no-update
               '''
            }
        }
        stage('SCA - GitLeaks') { 
            steps { 
               sh '''
               gitleaks detect --no-git -v --exit-code 0
               '''
            }
        }
        stage('SCA - OWASP Dependency Check') { 
            steps { 
               sh '''
               mvn dependency-check:aggregate
               '''
            }
        }
        stage('SAST - Sonarqube') { 
            steps { 
               sh '''
               mvn clean verify sonar:sonar   -Dsonar.projectKey=devsecfinops   -Dsonar.host.url=http://localhost:9000   -Dsonar.login=sqp_dc6e52d5bcf247728e9613bd6f027d36de1765a1
               '''
            }
        }
        stage('Build - Maven') { 
            steps { 
               sh '''
               mvn clean install -Dmaven.test.failure.ignore=true
               '''
            }
        }
        stage('Test - Junit') { 
            steps { 
               junit 'server/target/surefire-reports/**/*.xml'
            }
        }
        stage('IaC Scan - Terrascan') { 
            steps { 
               sh '''
               terrascan --version
               terrascan -l infra/ || true
               '''
            }
        }
        stage('FinOps Scan - Infracost') { 
            steps { 
               sh '''
               infracost --version
               infracost configure set api_key ico-jleTjQ1erlC5fXfHsJK5gumDcIGAX8Aj
               infracost breakdown --path infra/
               '''
            }
        }
        stage('Deploy - Apache Tomcat') { 
            steps { 
               deploy adapters: [tomcat9(url: 'http://localhost:8081/', 
                              credentialsId: 'tomcat')], 
                     war: '**/*.war',
                    contextPath: 'app'
            }
        }
        stage('DAST - Nikto Scan') { 
            steps { 
               sh '''
               nikto -Version
               nikto -h http://localhost:8081/app -output nikto-output.html
               '''
            }
        }
        stage('DAST - OWASP ZAP Scan') { 
            steps { 
               sh '''
               bash /opt/zaproxy/zap.sh -version
               bash /opt/zaproxy/zap.sh -cmd -quickurl "http://localhost:8081/app" -quickout /var/lib/jenkins/results.html -port 8082 -quickprogress
               '''
            }
        }
        stage ('End Time') {
            steps {
                sh '''
                    date
                ''' 
            }
        }
    }
}
