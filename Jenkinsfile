#!/usr/bin/env groovy
from jenkinsapi.jenkins import Jenkins

def getSCMInfroFromLatestGoodBuild(url, jobName, username=adong, password=Barton@679768):
    J = Jenkins(url, username, password)
    job = J[jobName]
    lgb = job.get_last_good_build()
    return lgb.get_revision()

def count；
def api_platform_version；
def good_version;
pipeline{
    agent{
        label "node-2xlarge"
    }
    environment{

    }
    options{
        buildDiscarder(

        )
        disableConcurrentBuilds(

        ) non
        skipDefaultCheckout(

        )
        timeout(

        )
        retry(

        )
        timestamps(

        )
    }
    parameters{
        string(

        )
        booleanParam(

        )
        choice(

        )
    }
    triggers{
        cron(

        )
        PollSCM(

        )
    }
    stages{
        stage('Clone sources'){

            steps{
                script{
                    sh ( script: "git clone https://github.elasticpath.net/commerce/ep-commerce.git")
                    api_platform_version = sh(script: "xmlstarlet sel -t -v /_:project/_:properties/_:api-platform.version pom.xml")
                }   
            }
        }
        stage('Verify'){
            steps{
                script{
                    sh (script: "wget -m https://nexus-master.elasticpath.net/nexus/content/repositories/ep-releases/com/elasticpath/rest/bill-of-materials/")
                    count = sh(script: "grep -c ${api_platform_version} nexus-master.elasticpath.net/nexus/content/repositories/ep-releases/com/elasticpath/rest/bill-of-materials/index.html")

                    }
                }
            }
        if(count == '0'){
            stage('Release api-platform'){
                steps{
                    script{

                    }
                }
            }
        }else{
            stage('Find pipeline ID'){
                steps{
                    script{
                        good_version = getSCMInfroFromLatestGoodBuild('http://builds.elasticpath.net/pd2/job/api-platform/job/api-platform/job/master/', 'PHASE:Build')
                        sh(script:"curl -X POST http://builds.elasticpath.net/pd2/job/api-platform/job/api-platform/job/master/${good_version} \
                                --user USER:TOKEN \
                                --data-urlencode json='{"parameter": [{"Restart from Stage":"PHASE: Release"}, {"Proceed":"yes"}]}'")
                    }
                }
            }
        }
    }
        
}
