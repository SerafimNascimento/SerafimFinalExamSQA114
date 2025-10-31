properties([
  parameters([
    string(name: 'TESTING_ENV',  defaultValue: '', description: 'Environment - TESTING'),
    string(name: 'STAGING_ENV',  defaultValue: '', description: 'Environment - STAGING'),
    string(name: 'PRODUCTION_ENV_1',    defaultValue: '', description: 'Environment - PRODUCTION_ENV1'),
    string(name: 'PRODUCTION_ENV_2',    defaultValue: '', description: 'Environment - PRODUCTION_ENV2'),
    string(name: 'REMOTE_DIRECTORY',    defaultValue: '/var/www/html', description: 'Remote Web Directory (Apache)'),
    string(name: 'SSH_KEY_PATH',  defaultValue: '/home/ec2-user/.ssh/finalexam.pem', description: 'SSH Key created by Terraform and copyed by the agent')
  ])
])

pipeline {
  agent none
  options { timestamps() }
  triggers { githubPush() }

  stages {
    stage('Checkout (permanent)') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        checkout scm
        echo "Targets:"
        echo "  Testing         -> ${params.TESTING_ENV}"
        echo "  Staging         -> ${params.STAGING_ENV}"
        echo "  Production_Env1 -> ${params.PRODUCTION_ENV_1}"
        echo "  Production_Env2 -> ${params.PRODUCTION_ENV_2}"
      }
    }

    stage('Deploy to TESTING') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        sh """
          set -e
          if [ -z "${params.TESTING_ENV}" ]; then
            echo "TESTING_ENV is empty"; exit 1
          fi
          scp -i ${params.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.TESTING_ENV}:${params.REMOTE_DIRECTORY}
        """
      }
    }

    stage('Selenium on TESTING') {
      agent { label 'JenkinsAgentDynamic' }
      steps {
        sh """
          set -e
          npm install selenium-webdriver --no-fund --no-audit
          BASE_URL=http://${params.TESTING_ENV}/ node tests/tic-tac-toe.test.js
        """
      }
    }

    stage('Deploy to STAGING') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        sh """
          set -e
          if [ -z "${params.STAGING_ENV}" ]; then
            echo "STAGING_ENV is empty"; exit 1
          fi
          scp -i ${params.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.STAGING_ENV}:${params.REMOTE_DIRECTORY}
        """
      }
    }

    stage('Selenium on STAGING') {
      agent { label 'JenkinsAgentDynamic' }
      steps {
        sh """
          set -e
          BASE_URL=http://${params.STAGING_ENV}/ node tests/tic-tac-toe.test.js
        """
      }
    }

    stage('Deploy to Production_Env1') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        sh """
          set -e
          if [ -z "${params.PRODUCTION_ENV_1}" ]; then
            echo "PRODUCTION_ENV_1 is empty"; exit 1
          fi
          scp -i ${params.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.PRODUCTION_ENV_1}:${params.REMOTE_DIRECTORY}
        """
      }
    }

    stage('Deploy to Production_Env2') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        sh """
          set -e
          if [ -z "${params.PRODUCTION_ENV_2}" ]; then
            echo "PRODUCTION_ENV_2 is empty"; exit 1
          fi
          scp -i ${params.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.PRODUCTION_ENV_2}:${params.REMOTE_DIRECTORY}
        """
      }
    }
  }

  post {
    always {
      node('JenkinsAgentPermanent') {
        archiveArtifacts artifacts: 'tests/**', onlyIfSuccessful: false
      }
    }
  }
}
