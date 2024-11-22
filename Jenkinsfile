pipeline {
  agent {
    docker {
      image 'node:alpine'
      reuseNode true
    }
  }

  stages {
    stage('Install Dependencies') {
      steps {
        echo 'Installing dependencies...'
        sh 'rm -rf node_modules package-lock.json && npm install'
      }
    }

    stage('Build') {
      steps {
        echo 'Building the project...'
        sh 'npm run build'
      }
    }

    stage('Static Analysis') {
      steps {
        echo 'Running static analysis...'
        sh './node_modules/eslint/bin/eslint.js -f checkstyle src > eslint.xml'
      }
      post {
        always {
          // Use the Warnings Next Generation Plugin to record issues from eslint.xml
          recordIssues enabledForFailure: true, aggregatingResults: true, tools: [checkStyle(pattern: 'eslint.xml')]
        }
      }
    }
  }

  post {
    always {
      echo 'Cleaning up workspace...'
      cleanWs()
    }
  }
}