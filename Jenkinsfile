pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                sh 'git submodule init'
                sh 'git submodule update'
            }
        }
        
        stage('Terraform Init'){
            steps{
                dir("deployments/${DEPLOYMENT_TYPE}"){
                    sh "terraform init -input=false"
                }
            }
        }
        
        stage('Terraform Plan'){
            steps{
                dir("deployments/${DEPLOYMENT_TYPE}"){
                    sh "terraform plan -out=tfplan -input=false"
                }
            }
        }

        stage('Terraform Apply'){
            steps{
                dir("deployments/${DEPLOYMENT_TYPE}"){
                    sh "aws s3api get-object --bucket jce-terraform-s3 --key ${DEPLOYMENT_TYPE}/terraform.tfvars terraform.tfvars"
                    sh "terraform apply -input=false tfplan"
                }
            }
        }
    }
}
