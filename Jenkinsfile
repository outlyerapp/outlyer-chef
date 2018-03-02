pipeline {
    agent any
    stages {
        stage('Build') {
            //when {
            //    branch 'master'
            //}
            //environment {
            //    AGENT_KEY = 'XXX-XXX-XXX-XXX-XXX'
            //    //BOX = 'outlyer-agent-centos-7'
            //}
            steps {
                git url: 'git@github.com:outlyerapp/outlyer-chef.git', branch: 'master'
                ansiColor('xterm') {
                    sh "./ci-build.sh"
                }
            }
        }
        stage('Verify') {
            //when {
            //    branch 'master'
            //}
            //environment {
            //    AUTH_TOKEN = 'xxx-xxx-xxx-xxx'
            //    //BOX = 'outlyer-agent-centos-7'
            //}
            steps {
                ansiColor('xterm') {
                    sh "./ci-verify.sh"
                }
            }
        }
    }
}
