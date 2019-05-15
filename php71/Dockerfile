FROM centos:latest
ARG PHP_VERSION=7.1.28
RUN yum -q clean all; \
    yum -y remove remi-release; \
    rm -f /etc/yum.repos.d/remi*; \
    yum -y --setopt=tsflags=nodocs install http://rpms.remirepo.net/enterprise/remi-release-7.rpm; \
    cp /etc/php.ini /tmp/php.ini.backup; \
    yum -y remove php*; \
    mv /tmp/php.ini.backup /etc/php.ini; \
    yum-config-manager --enable remi remi-php71; \
    yum-config-manager --disable remi-php70 remi-php72 remi-php73; \
    yum makecache; \
    yum -y --setopt=tsflags=nodocs install lsof zip unzip git sudo wget deltarpm gd-last php-${PHP_VERSION} php-bcmath-${PHP_VERSION} php-opcache-${PHP_VERSION} php-cli-${PHP_VERSION} php-common-${PHP_VERSION} php-gd-${PHP_VERSION} php-intl-${PHP_VERSION} php-json-${PHP_VERSION} php-mbstring-${PHP_VERSION} php-mcrypt-${PHP_VERSION} php-mysqlnd-${PHP_VERSION} php-pdo-${PHP_VERSION} php-pear php-fedora-autoloader php-process-${PHP_VERSION} php-soap-${PHP_VERSION} php-xml-${PHP_VERSION} php-pecl-zip php-pecl-xdebug; \
    mv /etc/php.d/15-xdebug.ini /etc/php.d/15-xdebug.ini.BAK; \
    php -v; php -m 