pipeline{
    agent any

        tools{
            jdk "Java-1.8"
        }
    stages{
        stage('Clone sources'){
            steps{
                git url: 'https://github.elasticpath.net/commerce/ep-commerce.git'
            }
        }
    }
}