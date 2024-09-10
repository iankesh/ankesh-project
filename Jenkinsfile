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
               trufflehog filesystem .
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
