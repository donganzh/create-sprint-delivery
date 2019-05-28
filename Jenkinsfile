def count =""
pipeline{
    agent any

        tools{
            jdk "Java-1.8"
        }
    stages{
        stage('Clone sources'){
            steps{
                script{
                    def previousTag = ""

                    if(GIT_BRANCH == "master"){
                        previousTag = sh (
                            label: "Get newest version Git tag",
							script: """
                                    git clone https://github.elasticpath.net/commerce/ep-commerce.git
                            """,
                            returnStdout: true
                        )
                    }

                    def api_platform_version = $(xmlstarlet sel -t -v /_:project/_:properties/_:api-platform.version pom.xml)
                }   
            }
        }
        stage('Verify'){
            steps{
                script{
                    if(GET_BRANCH == "master"){
                        script:"""
                                wget -m https://nexus-master.elasticpath.net/nexus/content/repositories/ep-releases/com/elasticpath/rest/bill-of-materials/ 
                        """
                    }
                    count = $(grep -c 1.26.0.9af7fe9e50 nexus-master.elasticpath.net/nexus/content/repositories/ep-releases/com/elasticpath/rest/bill-of-materials/index.html)
                }
            }
        }
    }
}