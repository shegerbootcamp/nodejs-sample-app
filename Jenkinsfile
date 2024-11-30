pipeline {
  agent any

  stages {
    stage('Install Dependencies') {
      agent {
        docker {
          image 'node:22-alpine'
          args '-u root'
        }
      }
      steps {
        echo 'Installing dependencies...'
        sh 'rm -rf node_modules package-lock.json && npm install'
      }
    }

    stage('Build') {
      agent {
        docker {
          image 'node:alpine'
          args '-u root'
        }
      }
      steps {
        echo 'Building the project...'
        sh 'npm run build'
      }
    }

    stage('Static Analysis') {
      agent {
        docker {
          image 'node:alpine'
          args '-u root'
        }
      }
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