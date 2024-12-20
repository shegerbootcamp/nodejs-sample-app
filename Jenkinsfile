pipeline {
  agent any

  stages {
    stage('Git Clone') {
      agent {
        docker {
          image 'node:22-alpine'
          args '-u root'
          reuseNode true
        }
      }
      steps {
        script {
          checkoutCode()
        }
      }
    }

    stage('Static Code Analysis') {
      parallel {
        stage('ESLint Test') {
          agent {
            docker {
              image 'node:22-alpine'
              args '-u root'
              reuseNode true
            }
          }
          when {
            expression { env.BRANCH_NAME != 'master' }
          }
          steps {
            script {
              runESLint()
            }
          }
        }

        stage('SonarQube Test') {
          agent {
            docker {
              image 'node:22-alpine'
              args '-u root'
              reuseNode true
            }
          }
          when {
            expression { env.BRANCH_NAME == 'master' }
          }
          steps {
            script {
              runSonarQube()
            }
          }
        }
      }
    }

    stage('Build') {
      agent {
        docker {
          image 'node:22-alpine'
          args '-u root'
          reuseNode true
        }
      }
      steps {
        script {
          buildApp()
        }
      }
    }

    stage('Home Page Test') {
      steps {
        script {
          testHomePage('http://localhost:8443')
        }
      }
    }

    stage('Build Docker Image') {
      agent {
        docker {
          image 'node:22-alpine'
          args '-u root'
          reuseNode true
        }
      }
      steps {
        script {
          buildDockerImage('my-app')
        }
      }
    }

    stage('Push Docker Image') {
      agent {
        docker {
          image 'node:22-alpine'
          args '-u root'
          reuseNode true
        }
      }
      steps {
        script {
          pushDockerImage('my-app')
        }
      }
    }
  }

  post {
    always {
      echo 'Cleaning up workspace...'
      cleanWs()
    }
    success {
      echo 'Pipeline completed successfully!'
    }
    failure {
      echo 'Pipeline failed. Check the logs for details.'
    }
  }
}

def checkoutCode() {
  echo 'Cloning repository...'
  checkout scm
}

def runESLint() {
  echo 'Running ESLint for non-master branches...'
  sh 'npm run lint'
}

def runSonarQube() {
  echo 'Running SonarQube analysis for master branch...'
  // Assuming you have SonarQube configured in Jenkins
  sh 'npm install -g sonarqube-scanner'
  sh 'sonar-scanner'
}

def buildApp() {
  echo 'Building the app...'
  sh 'npm run build'
}

def testHomePage(url) {
  echo "Waiting for the app to start at '${url}'..."
  retry(3) {
    sleep 5
    sh "curl -f ${url} || exit 1"
  }

  echo "Testing the home page at '${url}'..."
  // Test the page content for a specific title
  sh """
  CONTENT=\$(curl -s ${url})
  TITLE=\$(echo "\$CONTENT" | grep -oP '(?<=<title>).*?(?=</title>)')
  if [ "\$TITLE" == "Titan" ]; then
    echo "Home page title test passed: \$TITLE"
  else
    echo "Home page title test failed. Expected: 'Titan', Got: \$TITLE"
    exit 1
  fi
  """
}

def buildDockerImage(imageName) {
  echo "Building Docker image '${imageName}'..."
  sh "docker build -t ${imageName} ."
}

def pushDockerImage(imageName) {
  echo "Pushing Docker image '${imageName}' to registry..."
  sh "docker push ${imageName}"
}