pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = "true"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-terraform-creds'
                ]]) {
                    dir('env/dev') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-terraform-creds'
                ]]) {
                    dir('env/dev') {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-terraform-creds'
                ]]) {
                    dir('env/dev') {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Approval') {
            steps {
                input message: "Approve Terraform Apply?"
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-terraform-creds'
                ]]) {
                    dir('env/dev') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Destroy Dev (Manual)') {
            steps {
                input message: 'Destroy DEV environment?'
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-terraform-creds'
                ]]) {
                    dir('env/dev') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }

    }
}