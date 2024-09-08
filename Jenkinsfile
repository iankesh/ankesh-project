pipeline { 
    agent any
    stages {
        stage ('Initialize') {
            steps {
                sh '''
                    echo "JAVA_HOME = $JAVA_HOME"
                    echo "M2_HOME = $M2_HOME"
                ''' 
            }
        }
        stage('Build') { 
            steps { 
               sh '''
               mvn -Dmaven.test.failure.ignore=true install
               '''
            }
        }
    }
}
