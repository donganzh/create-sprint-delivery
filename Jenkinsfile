#!/usr/bin/env groovy

def count；
def api_platform_version；
def pipeline_id;
def newsuccessfulbuild;
def lastsuccessfulbuild;
def numBuild = 0;
def numRelease = 0;
def platform_version;
def release_api_plaform;

pipeline{
    agent{ 
        label "node-2xlarge"
    }
    stages{
        stage('Clone sources'){//step 1
            steps{
                script{
                    deleteDir()
                    dir('ep-commerce') {
                            git 'https://github.elasticpath.net/commerce/ep-commerce.git'
                    }
                    api_platform_version = sh(script: "xmlstarlet sel -t -v /_:project/_:properties/_:api-platform.version ${WORKSPACE}/ep-commerce/pom.xml",
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
                            wget https://nexus-master.elasticpath.net/nexus/content/repositories/ep-releases/com/elasticpath/rest/bill-of-materials/
                        """)
                    count = sh(script: "grep -c ${api_platform_version} ${WORKSPACE}/index.html || :",
                                returnStdout: true
                    ).trim()
                    echo count
                    release_api_plaform = (count == 0) ? true : false
                    }
                }
            }
       
        stage('Release api-platform'){//step 3
            when {
                not{
                expression{release_api_plaform}
                }
            }
            steps{
                script{ 
                    // numBuild = sh(script:"wget -qO- http://builds.elasticpath.net/pd2/job/api-platform/job/api-platform/job/master/lastSuccessfulBuild/buildNumber",
                    //                         returnStdout: true).trim()
                    // echo numBuild
                    numBuild = 28
                    while(numBuild > 0){
                        withCredentials([usernameColonPassword(credentialsId: 'ep-ad-user-buildadmin', variable: 'BUILDADMIN_CREDENTIAL')]) {
                        sh(script:
                            """
                                curl -X GET -u '${BUILDADMIN_CREDENTIAL}' -o task_api_platform.json http://builds.elasticpath.net/pd2/job/api-platform/job/api-platform/job/master/${numBuild}/api/json
                            """)
                        }
                        platform_version = sh (script:"jq -r '.description' task_api_platform.json",
                                            returnStdout: true).trim()
                        echo platform_version
                        if(platform_version.contains(api_platform_version)){
                            numRelease = numBuild
                            break
                        }else{
                            numBuild--
                            echo numBuild
                        }
                        
                    }

                    echo numRelease
                    withCredentials([usernameColonPassword(credentialsId: 'ep-ad-user-buildadmin', variable: 'BUILDADMIN_CREDENTIAL')]) {
                    sh("""
                        curl -X POST \
                        -u '${BUILDADMIN_CREDENTIAL}' \
                        http://builds.elasticpath.net/pd2/job/api-platform/job/api-platform_release/buildWithParameters?PROJECT_CI_JOB_BUILD_NUMBER=${numRelease}
                        """)
                    }   
                }
            }
        }    
        
        stage('Find pipeline ID'){//step 4
            steps{
                script{
                    sh(script:
                        """
                            wget http://builds.elasticpath.net/pd/job/master/job/task_release-ep-commerce/lastSuccessfulBuild/api/json -O task_release-ep-commerce_lastSuccessfulBuild.json
                        """)
                        pipeline_id = sh(script: "jq -r '.actions[0].parameters[] | select (.name == \"PIPELINE_BUILD_ID\") | .value' task_release-ep-commerce_lastSuccessfulBuild.json",
                                        returnStdout: true
                                        ).trim()
                        echo pipeline_id
                }
            }
        }
        
        stage('Release stage git branch to git repo'){//step 5
            steps{
                script{
                    withCredentials([usernameColonPassword(credentialsId: 'ep-ad-user-buildadmin', variable: 'BUILDADMIN_CREDENTIAL')]) {
                    sh("""
                        curl -X POST \
                        -u '${BUILDADMIN_CREDENTIAL}' \
                        'http://builds.elasticpath.net/pd/job/master/job/release_stage-git-branch-to-git-repository/buildWithParameters?PIPELINE_BUILD_ID=${pipeline_id}&SOURCE_GIT_URL=git@github.elasticpath.net:ep-source-deploy/ep-commerce.git&SOURCE_GIT_BRANCH=${pipeline_id}&STAGING_GIT_URL=git@code.elasticpath.com:ep-commerce-STAGING/ep-commerce.git&STAGING_GIT_BRANCH=release/next&FORCE_PUSH=true'
                    """)
                    }
                    lastsuccessfulbuild = sh(script:'wget -qO- http://builds.elasticpath.net/pd/job/master/job/release_stage-git-branch-to-git-repository/lastSuccessfulBuild/buildNumber',
                                            returnStdout: true).trim()
                    newsuccessfulbuild = sh(script:'wget -qO- http://builds.elasticpath.net/pd/job/master/job/release_stage-git-branch-to-git-repository/lastSuccessfulBuild/buildNumber',
                                            returnStdout: true).trim()
                    while(lastsuccessfulbuild == newsuccessfulbuild){
                        newsuccessfulbuild = sh(script:'wget -qO- http://builds.elasticpath.net/pd/job/master/job/release_stage-git-branch-to-git-repository/lastSuccessfulBuild/buildNumber',
                                                returnStdout: true).trim()
                        echo lastsuccessfulbuild
                        echo newsuccessfulbuild
                    }
                }
            }
        }
        stage('Build gitlab staging epc branch'){//step 6
            steps{
                script{
                    withCredentials([usernameColonPassword(credentialsId: 'ep-ad-user-buildadmin', variable: 'BUILDADMIN_CREDENTIAL')]) {
                    sh("""
                        curl -X POST \
                        -u '${BUILDADMIN_CREDENTIAL}' \
                        http://builds.elasticpath.net/pd/view/Support/job/epc-patch/job/build-gitlab-staging-epc-branch/buildWithParameters?VERSION=next
                        """)
                    }
                }
            }
        }        
    }        
}
