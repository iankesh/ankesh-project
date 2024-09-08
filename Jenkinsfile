pipeline { 
    agent any
    stages {
        stage ('Initialize') {
            steps {
                sh '''
                    pwd
                    mvn clean install
                ''' 
            }
        }
        stage('Build') { 
            steps { 
               echo 'This is a minimal pipeline.' 
            }
        }
    }
}
