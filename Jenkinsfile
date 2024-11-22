pipeline {
  agent { label 'linux' }

  stages {
    stage('Build') {
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
            sh 'npm ci'
          }
        }

        stage('Static Analysis') {
          parallel {
            stage('Lint') {
              steps {
                echo 'Linting...'
                // catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                catchError {
                  sh 'npm run eslint -- -f checkstyle -o eslint.xml'
                }
              }
              post {
                always {
                  // Warnings Next Generation Plugin
                  recordIssues enabledForFailure: true, tools: [esLint(pattern: 'eslint.xml')]
                }
              }
            }

            stage('Typecheck') {
              steps {
                echo 'Type Checking...'
                sh 'npx tsc -p . --noEmit'
              }
            }
          }
        }

        stage('Build') {
          environment {
            NODE_ENV = 'production'
          }
          steps {
            echo 'Building..'
            sh 'npm run build'
          }
        }
      }
    }
    stage('Integration Tests') {
      steps {
        script {
          docker.image('postgres:alpine').withRun('-e "POSTGRES_PASSWORD=password" -e "POSTGRES_DB=test"') {c ->
            docker.image('node:alpine').inside("--link ${c.id}:db") {
              // sh 'npm ci'
              sh 'npm run test'
            }
          }
        }
      }
    }
  }
}