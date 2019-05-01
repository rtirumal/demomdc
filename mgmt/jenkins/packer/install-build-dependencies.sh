#!/bin/bash
# Install dependencies used by Jenkins builds, such as Terraform, Terragrunt, Packer, and Docker

set -e

readonly TERRAFORM_VERSION="0.11.8"
readonly TERRAGRUNT_VERSION="v0.17.1"
readonly PACKER_VERSION="1.0.0"
readonly DOCKER_VERSION="18.06.1"
readonly JENKINS_USER="jenkins"

function install_terraform {
    local readonly version="$1"
    
    echo "Installing Terraform $version"
    wget "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip"
    unzip "terraform_${version}_linux_amd64.zip"
    sudo cp terraform /usr/local/bin/terraform
    sudo chmod a+x /usr/local/bin/terraform
}

function install_terragrunt {
    local readonly version="$1"
    
    echo "Installing Terragrunt $version"
    wget "https://github.com/gruntwork-io/terragrunt/releases/download/$version/terragrunt_linux_amd64"
    sudo cp terragrunt_linux_amd64 /usr/local/bin/terragrunt
    sudo chmod a+x /usr/local/bin/terragrunt
}

function install_packer {
    local readonly version="$1"
    
    echo "Installing Packer $version"
    wget "https://releases.hashicorp.com/packer/${version}/packer_${version}_linux_amd64.zip"
    unzip "packer_${version}_linux_amd64.zip"
    sudo cp packer /usr/local/bin/packer
    sudo chmod a+x /usr/local/bin/packer
}

# Based on: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html for Amazon Linux 2
function install_docker {
    local readonly version="$1"
    
    echo "Installing Docker $version"
    sudo amazon-linux-extras install docker=${version}
    
    # This allows us to run Docker without sudo: http://askubuntu.com/a/477554
    echo "Adding user $JENKINS_USER to Docker group"
    sudo gpasswd -a "$JENKINS_USER" docker
    echo "Adding user ec2-user to Docker group"
    sudo usermod -a -G docker ec2-user
}

function install_git {
    echo "Installing Git"
    sudo yum install -y git
}

function install {
    install_terraform "$TERRAFORM_VERSION"
    install_terragrunt "$TERRAGRUNT_VERSION"
    install_packer "$PACKER_VERSION"
    install_docker
    install_git
}

install