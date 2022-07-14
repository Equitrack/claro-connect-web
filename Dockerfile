FROM nexus-admin.videoconferenciaclaro.com/atomic-rhel7-nginx-php-fpm72

# :RUN curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo

# Verify ImageMagick version on https://imagemagick.org/download/linux/CentOS/x86_64/. It changes very often.
RUN microdnf clean all \
    && microdnf install -y zip unzip git zlib-devel libcurl-devel openssl-devel libxml2-devel rh-php72-php-devel pcre-devel yum gcc \
    && microdnf clean all \
    && curl -u 'docker-user:J4?bF4cV5lx4;*|gW4' https://nexus-admin.videoconferenciaclaro.com/repository/videoconferencia_claro/imagemagick/ImageMagick-libs-7.0.10-25.x86_64.rpm -O \
    && curl -u 'docker-user:J4?bF4cV5lx4;*|gW4' https://nexus-admin.videoconferenciaclaro.com/repository/videoconferencia_claro/imagemagick/ImageMagick-7.0.10-25.x86_64.rpm -O \
    && curl -u 'docker-user:J4?bF4cV5lx4;*|gW4' https://nexus-admin.videoconferenciaclaro.com/repository/videoconferencia_claro/imagemagick/ImageMagick-devel-7.0.10-25.x86_64.rpm -O \
    && yum install -y https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/l/libraqm-0.7.0-4.el7.x86_64.rpm ; yum clean all \
    && yum install -y ImageMagick-libs-7.0.10-25.x86_64.rpm ; yum clean all \
    && yum install -y ImageMagick-7.0.10-25.x86_64.rpm ; yum clean all \
    && yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/libwebp-devel-0.3.0-7.el7.x86_64.rpm ; yum clean all \
    && yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/lcms2-devel-2.6-3.el7.x86_64.rpm ; yum clean all \
    && yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/libgs-devel-9.25-2.el7_7.3.x86_64.rpm ; yum clean all \
    && yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/openjpeg2-tools-2.3.1-3.el7_7.x86_64.rpm ; yum clean all \
    && yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/openjpeg2-devel-2.3.1-3.el7_7.x86_64.rpm ; yum clean all \
    && yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/ilmbase-devel-1.0.3-7.el7.x86_64.rpm ; yum clean all \
    && yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/OpenEXR-devel-1.7.1-7.el7.x86_64.rpm ; yum clean all \
    && yum install -y ImageMagick-devel-7.0.10-25.x86_64.rpm ; yum clean all \
    && yum install -y https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/l/libmcrypt-2.5.8-13.el7.x86_64.rpm ; yum clean all \
    && yum install https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/l/libmcrypt-devel-2.5.8-13.el7.x86_64.rpm -y ; yum clean all \
    && pecl channel-update pecl.php.net \
    && pecl install imagick \
    && pecl install mcrypt \
    && pecl install mongodb \
    && echo "extension=mongodb.so" >> /etc/opt/rh/rh-php72/php.ini \
    && echo "extension=mcrypt.so" >> /etc/opt/rh/rh-php72/php.ini \
    && echo "extension=imagick.so" >> /etc/opt/rh/rh-php72/php.ini \
    && sed -i 's/allow_url_fopen.*/allow_url_fopen = On/g' /etc/opt/rh/rh-php72/php.ini \
    && rm -f ImageMagick* \
    && microdnf remove \
        autoconf \
        automake \
        cpp \
        gcc \
        gcc-c++\
        glibc-devel \
        glibc-headers \
        libmpc \
        m4 \
        mpfr \
        openssl-devel \
        pcre-devel \
        rh-php72-php-devel \
        yum  \
        libwebp-devel \
        lcms2-devel \
        libgs-devel \
        openjpeg2-devel \
        ilmbase-devel \
        OpenEXR-devel \
        ImageMagick-devel \
        libselinux-devel \
        krb5-devel \
        libmcrypt-devel \
    && microdnf clean all
