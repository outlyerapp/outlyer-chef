pipeline {
    agent any
    stages {
        stage('Test') {
            //when {
            //    branch 'master'
            //}
            //environment {
            //    AGENT_KEY = 'XXX-XXX-XXX-XXX-XXX'
            //    //BOX = 'outlyer-agent-centos-7'
            //    AUTH_TOKEN = 'XXX.XXX.XXX-XXX-XXX'
            //}
            steps {
                // git url: 'git@github.com:outlyerapp/outlyer-chef.git', branch: 'master'
                ansiColor('xterm') {
                    sh "./pre-test.sh"
                    sh "kitchen test $BOX"
                }
            }
        }
    }
}
