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
        stage('Secrets Scanner - TruffleHog') { 
            steps { 
               sh '''
               trufflehog --version
               trufflehog git https://github.com/iankesh/ankesh-project --no-update
               '''
            }
        }
        stage('OWASP Dependency Check') { 
            steps { 
               sh '''
               mvn dependency-check:aggregate
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
        stage('FinOps - Infracost') { 
            steps { 
               sh '''
               infracost --version
               infracost configure set api_key ico-jleTjQ1erlC5fXfHsJK5gumDcIGAX8Aj
               infracost breakdown --path infra/
               '''
            }
        }
        stage('IaC - Terraform') { 
            steps { 
               sh '''
               terraform version
               export TF_TOKEN_app_terraform_io=40P8f2zzqjCleQ.atlasv1.ZVmzC2D08wM8AZC3wDgH2ozc1GcjfbAIz7x7RpU67eT1CyODmVdAWqih1chduOQDjYU
               cd infra
               terraform init
               terraform plan -lock=false
               cd ..
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
        stage ('End Time') {
            steps {
                sh '''
                    date
                ''' 
            }
        }
    }
}
