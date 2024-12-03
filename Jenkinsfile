pipeline {
  agent any

  stages {
    stage('Git Clone') {
      steps {
        script {
          checkoutCode()
        }
      }
    }

    stage('Static Code Analysis') {
      parallel {
        stage('ESLint Test') {
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
      steps {
        script {
          buildDockerImage('my-app')
        }
      }
    }

    stage('Push Docker Image') {
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
  echo "Testing the home page at '${url}'..."
  // Check if the home page is accessible and contains expected content
  sh """
  STATUS=\$(curl -s -o /dev/null -w "%{http_code}" ${url})
  if [ "\$STATUS" -ne 200 ]; then
    echo "Home page test failed: HTTP \$STATUS"
    exit 1
  fi

  # Optionally, you can also check for specific content on the home page
  CONTENT=\$(curl -s ${url})
  if [[ "\$CONTENT" == *"Welcome to the homepage!"* ]]; then
    echo "Home page test passed!"
  else
    echo "Home page test failed: Content not found."
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