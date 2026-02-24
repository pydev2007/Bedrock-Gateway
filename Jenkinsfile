def terraform_secrets = [
  [
    path: 'secrets/creds/gavin_terraform_aws',
    engineVersion: 1,
    secretValues: [
      [envVar: 'AWS_ACCESS_KEY_ID', vaultKey: 'terraform_aws_id'],
      [envVar: 'AWS_SECRET_ACCESS_KEY', vaultKey: 'terraform_aws_key']
    ]
  ]
]

def jenkins_secrets = [
  [
    path: 'secrets/creds/Jenkins_AWS',
    engineVersion: 1,
    secretValues: [
      [envVar: 'AWS_ACCESS_KEY_ID', vaultKey: 'jenkins_aws_id'],
      [envVar: 'AWS_SECRET_ACCESS_KEY', vaultKey: 'jenkins_aws_key']
    ]
  ]
]


def configuration = [
  vaultUrl: 'http://192.168.86.246:8200',
  vaultCredentialId: 'vault-jenkins-role',
  engineVersion: 1
]

pipeline {
    agent { label 'GavinWSL' }

    parameters {
        booleanParam(name: 'TEARDOWN', defaultValue: false, description: 'Destroy ECR repository instead of building')
        string(name: 'REPO_NAME', defaultValue: 'bedrock-gateway', description: 'ECR repository name')
        string(name: 'AWS_ID', defaultValue: '107456217315', description: 'AWS Account ID')
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_URL = "${params.AWS_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
    }

    stages {

        stage('Build') {
            when {
                expression { return params.TEARDOWN == false }
            }
            steps {
                sh 'git clone https://github.com/aws-samples/bedrock-access-gateway.git'

                sh """
                    cd bedrock-access-gateway/src/
                    docker build -f Dockerfile -t ${params.REPO_NAME}:latest .
                """

                script {
                    def imageId = sh(
                        script: "docker images --filter reference=${params.REPO_NAME}:latest --quiet --no-trunc",
                        returnStdout: true
                    ).trim()

                    env.IMAGE_ID = imageId
                    echo "Built Image ID: ${env.IMAGE_ID}"
                }
            }
        }

        stage('Push to ECR') {
            when {
                expression { return params.TEARDOWN == false }
            }
            steps {
                withVault([configuration: configuration, vaultSecrets: jenkins_secrets]) {

                    sh """
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} \
                        | docker login --username AWS --password-stdin ${ECR_URL}
                    """

                    // Create repo if it doesn't exist
                    sh """
                        aws ecr describe-repositories \
                        --repository-names ${params.REPO_NAME} \
                        --region ${AWS_DEFAULT_REGION} \
                        || aws ecr create-repository \
                        --repository-name ${params.REPO_NAME} \
                        --region ${AWS_DEFAULT_REGION}
                    """

                    sh """
                        docker tag ${params.REPO_NAME}:latest ${ECR_URL}/${params.REPO_NAME}:latest
                        docker push ${ECR_URL}/${params.REPO_NAME}:latest
                    """
                }
            }
        }

        stage('Remove from ECR') {
            when {
                expression { return params.TEARDOWN == true }
            }
            steps {
                script {
                    try {
                        withVault([configuration: configuration, vaultSecrets: jenkins_secrets]) {

                            sh """
                                aws ecr get-login-password --region ${AWS_DEFAULT_REGION} \
                                | docker login --username AWS --password-stdin ${ECR_URL}
                            """

                            sh """
                                aws ecr delete-repository \
                                --repository-name ${params.REPO_NAME} \
                                --region ${AWS_DEFAULT_REGION} \
                                --force
                            """
                        }
                    } catch (err) {
                        echo "Repository may not exist: ${err.getMessage()}"
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                expression { return params.TEARDOWN == false }
            }
            steps {
                script {
                    withVault([configuration: configuration, vaultSecrets: jenkins_secrets]) {
                        sh '''
                        docker run --rm \
                        -e AWS_ACCESS_KEY_ID \
                        -e AWS_SECRET_ACCESS_KEY \
                        -e AWS_DEFAULT_REGION \
                        -v "$PWD":/workspace \
                        -w /workspace \
                        tfdev:latest
                        '''
                        sh "pwd"
                        sh "terraform init"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                try {
                    if (env.IMAGE_ID) {
                        sh "docker image rm ${env.IMAGE_ID} || true"
                    }
                } catch (err) {
                    echo "Image cleanup failed: ${err.getMessage()}"
                } finally {
                    cleanWs()
                }
            }
        }
    }
}
