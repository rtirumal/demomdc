#!/bin/bash
# Install the Gruntwork modules used by a Jenkins server.

set -e

readonly GRUNTWORK_INSTALL_VERSION="v0.0.21"
readonly GRUNTKMS_VERSION="v0.0.7"
readonly MODULE_SECURITY_VERSION="v0.15.4"
readonly MODULE_AWS_MONITORING_VERSION="v0.10.0"
readonly MODULE_STATEFUL_SERVER_VERSION="v0.5.0"
readonly MODULE_CI_VERSION="v0.13.3"
readonly JENKINS_VERSION="2.138.2"

function print_usage {
    echo
    echo "Usage: install-gruntwork-modules.sh"
    echo
    echo "Install the Gruntwork modules used by a Jenkins server."
    echo
    echo "This script is configured via environment variables so it's easy to use with Packer:"
    echo
    echo -e "  AWS_REGION\t\t\tThe AWS region this server will be deployed to. Required."
    echo
    echo "Example:"
    echo
    echo "  AWS_REGION=eu-west-1"
}


function install_monitoring_packages {
    local readonly module_aws_monitoring_version="$1"
    local readonly aws_region="$2"
    
    echo "Installing Gruntwork Monitoring Modules"
    
    gruntwork-install --module-name 'logs/cloudwatch-log-aggregation-scripts' --repo https://github.com/gruntwork-io/module-aws-monitoring --tag "$module_aws_monitoring_version" --module-param aws-region="$aws_region"
    gruntwork-install --module-name 'metrics/cloudwatch-memory-disk-metrics-scripts' --repo https://github.com/gruntwork-io/module-aws-monitoring --tag "$module_aws_monitoring_version"
    gruntwork-install --module-name 'logs/syslog' --repo https://github.com/gruntwork-io/module-aws-monitoring --tag "$module_aws_monitoring_version"
}

function install_stateful_server_packages {
    local readonly module_server_version="$1"
    
    echo "Installing Gruntwork Stateful Server Modules"
    gruntwork-install --module-name 'persistent-ebs-volume' --repo 'https://github.com/gruntwork-io/module-server' --tag "$module_server_version"
}

function install_ci_packages {
    local readonly module_ci_version="$1"
    local readonly jenkins_version="$2"
    
    echo "Installing Gruntwork CI Modules"
    
    gruntwork-install --module-name 'install-jenkins' --repo 'https://github.com/gruntwork-io/module-ci' --tag "$module_ci_version" --module-param "version=$jenkins_version"
    gruntwork-install --module-name 'build-helpers' --repo 'https://github.com/gruntwork-io/module-ci' --tag "$module_ci_version"
    gruntwork-install --module-name 'git-helpers' --repo 'https://github.com/gruntwork-io/module-ci' --tag "$module_ci_version"
    gruntwork-install --module-name 'terraform-helpers' --repo 'https://github.com/gruntwork-io/module-ci' --tag "$module_ci_version"
}

function assert_env_var_not_empty {
    local readonly var_name="$1"
    local readonly var_value="${!var_name}"
    
    if [[ -z "$var_value" ]]; then
        echo "ERROR: Required environment variable $var_name not set."
        print_usage
        exit 1
    fi
}

function install_bash_commons {
    local -r bash_commons_version="$1"
    
    echo "Installing bash-commons version $bash_commons_version"
    gruntwork-install --module-name 'bash-commons' --repo https://github.com/gruntwork-io/bash-commons --tag "$bash_commons_version"
}

function install_gruntwork_modules {
    assert_env_var_not_empty "GITHUB_OAUTH_TOKEN"
    assert_env_var_not_empty "AWS_REGION"
    
    
    local aws_region="$AWS_REGION"
    
    
    curl -Ls https://raw.githubusercontent.com/gruntwork-io/gruntwork-installer/master/bootstrap-gruntwork-installer.sh | bash /dev/stdin --version "$GRUNTWORK_INSTALL_VERSION"
    
    install_bash_commons "v0.0.7"
    install_monitoring_packages "$MODULE_AWS_MONITORING_VERSION" "$aws_region"
    install_stateful_server_packages "$MODULE_STATEFUL_SERVER_VERSION"
    install_ci_packages "$MODULE_CI_VERSION" "$JENKINS_VERSION"
}

# adding this hack to allow install on Amazon Linux 2 (which is basically centos 7.3)


install_gruntwork_modules