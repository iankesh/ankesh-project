pipeline { 
    agent any
    stages {
        stage ('Initialize') {
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
        stage('Build') { 
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
        stage('Deploy') { 
            steps { 
               deploy adapters: [tomcat9(url: 'http://localhost:8081/', 
                              credentialsId: 'tomcat')], 
                     war: '**/*.war'
            }
        }
    }
}
