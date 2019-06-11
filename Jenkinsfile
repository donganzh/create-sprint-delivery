#!/usr/bin/env groovy

def count；
def api_platform_version；
def pipeline_id;
pipeline{
    agent{
        label "node-2xlarge"
    }
    stages{
        stage('Clone sources'){//step 1
            steps{
                script{
                    
                    sh ( script: """
                            if [ ! -d "/home/ec2-user/jenkins_home/workspace/automation/create-sprint-delivery/ep-commerce" ]; then
                                git clone https://github.elasticpath.net/commerce/ep-commerce.git
                             else
                                echo "Directory already exists."
                            fi
                            """)
                    api_platform_version = sh(script: "xmlstarlet sel -t -v /_:project/_:properties/_:api-platform.version /home/ec2-user/jenkins_home/workspace/automation/create-sprint-delivery/ep-commerce/pom.xml",
                                            returnStdout: true
                    ).trim()
                    echo api_platform_version
                }   
            }
        }
        stage('Verify'){//step 2
            steps{
                script{
                    sh (script: """
                        if [ ! -f /home/ec2-user/jenkins_home/workspace/automation/create-sprint-delivery/index.html ]; then
                            wget https://nexus-master.elasticpath.net/nexus/content/repositories/ep-releases/com/elasticpath/rest/bill-of-materials/
                        else
                            echo "File already exists."
                        fi
                        """)
                    count = sh(script: "grep -c ${api_platform_version} /home/ec2-user/jenkins_home/workspace/automation/create-sprint-delivery/index.html",
                                returnStdout: true
                    ).trim()
                    echo count
                    }
                }
            }
       
        stage('Release api-platform'){//step 3
            steps{
                script{ 
                    if(count == 0){
                        sh(script:"""curl -X POST http://builds.elasticpath.net/pd2/job/api-platform/job/api-platform/job/master/build?token=12345 \
                                --data-urlencode json='{"parameter": [{"RELEASE_LEVEL":"minor"}]}'""")     
                    }
                }
            }
        }    
        
        stage('Find pipeline ID'){//step 4
            steps{
                script{
                    if(count > 0){
                        sh(script:
                        """
                            wget http://builds.elasticpath.net/pd/job/master/job/task_release-ep-commerce/lastSuccessfulBuild/api/json -O task_release-ep-commerce_lastSuccessfulBuild.json
                        """)
                        pipeline_id = sh(script: "jq -r '.actions[0].parameters[5].value' task_release-ep-commerce_lastSuccessfulBuild.json",
                            returnStdout: true
                        ).trim()
                        echo pipeline_id
                    }
                }
            }
        }
        
        stage('Release stage git branch to git repo'){//step 5
            steps{
                script{
                    sh(script:"""curl -X POST http://builds.elasticpath.net/pd/job/master/job/release_stage-git-branch-to-git-repository/build?token=12345 --data-urlencode json='{"parameter": [{"SOURCE_GIT_URL":"git@github.elasticpath.net:ep-source-deploy/ep-commerce.git","SOURCE_GIT_BRANCH":"${pipeline_id}", "STAGING_GIT_URL":"git@code.elasticpath.com:ep-commerce-STAGING/ep-commerce.git","STAGING_GIT_BRANCH":"release/next","FORCE_PUSH":"true", "PIPELINE_BUILD_ID":"${pipeline_id}"]}' """
                        )
                }
            }
        }
        stage('Build gitlab staging epc branch'){
            steps{
                script{
                    sh(script:"""curl -X POST http://10.11.12.13/pd/view/Support/job/epc-patch/job/build-gitlab-staging-epc-branch/build?token=12345 --data-urlencode json='{"parameter": [{"VERSION":"next"}]}'""")
                }
            }
        }
        
    }
        
}
