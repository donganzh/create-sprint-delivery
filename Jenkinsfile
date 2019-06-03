#!/usr/bin/env groovy

def getSCMInfroFromLatestGoodBuild(url, jobName, username='adong', password='Barton@679768'){
    J = Jenkins(url, username, password)
    job = J[jobName]
    lgb = job.get_last_good_build()
    return lgb.get_revision()
}

def count；
def api_platform_version；
def good_version;
def pipeline_id;
pipeline{
    agent{
        label "node-2xlarge"
    }
    // environment{

    // }
    // options{
    //     buildDiscarder(

    //     )
    //     disableConcurrentBuilds(

    //     ) non
    //     skipDefaultCheckout(

    //     )
    //     timeout(

    //     )
    //     retry(

    //     )
    //     timestamps(

    //     )
    // }
    // parameters{
    //     string(

    //     )
    //     booleanParam(

    //     )
    //     choice(

    //     )
    // }
    // triggers{
    //     cron(

    //     )
    //     PollSCM(

    //     )
    // }
    stages{
        stage('Clone sources'){//step 1
            steps{
                script{
                    sh ( script: "git clone https://github.elasticpath.net/commerce/ep-commerce.git")
                    api_platform_version = sh(script: "xmlstarlet sel -t -v /_:project/_:properties/_:api-platform.version pom.xml")
                }   
            }
        }
        stage('Verify'){//step 2
            steps{
                script{
                    sh (script: "wget -m https://nexus-master.elasticpath.net/nexus/content/repositories/ep-releases/com/elasticpath/rest/bill-of-materials/")
                    count = sh(script: "grep -c ${api_platform_version} nexus-master.elasticpath.net/nexus/content/repositories/ep-releases/com/elasticpath/rest/bill-of-materials/index.html")

                    }
                }
            }
        if(count == '0'){
            stage('Release api-platform'){//step 3
                steps{
                    script{
                        good_version = getSCMInfroFromLatestGoodBuild('http://builds.elasticpath.net/pd2/job/api-platform/job/api-platform/job/master/')
                        sh(script:"""curl -X POST http://builds.elasticpath.net/pd2/job/api-platform/job/api-platform/job/master/build?token=12345 \
                                    --data-urlencode json='{"parameter": [{"RELEASE_LEVEL":"minor"}]}'""")
                    }
                }
            }
        }else{
            stage('Find pipeline ID'){//step 4
                steps{
                    script{
                        pipeline_id = getSCMInfroFromLatestGoodBuild('http://builds.elasticpath.net/pd/job/master/job/task_release-ep-commerce/')
                    }
                }
            }
        }
        stage('Release stage git branch to git repo'){//step 5
            steps{
                script{
                    sh(script:"""curl -X POST http://builds.elasticpath.net/pd/job/master/job/release_stage-git-branch-to-git-repository/build?token=12345 
                                --data-urlencode json='{"parameter": [{"SOURCE_GIT_URL":"git@github.elasticpath.net:ep-source-deploy/ep-commerce.git", 
                                "SOURCE_GIT_BRANCH":"${pipeline}", "STAGING_GIT_URL":"git@code.elasticpath.com:ep-commerce-STAGING/ep-commerce.git","STAGING_GIT_BRANCH":"release/next",
                                "FORCE_PUSH":"true", "PIPELINE_BUILD_ID":"${pipeline}"]}' """)
                }
            }
        }
        stage('Build gitlab staging epc branch'){
            steps{
                script{
                    sh(script:"""curl -X POST http://10.11.12.13/pd/view/Support/job/epc-patch/job/build-gitlab-staging-epc-branch/build?token=12345 \
                                    --data-urlencode json='{"parameter": [{"VERSION":"next"}]}'""")
                }
            }
        }
        
    }
        
}
