FROM nexus-admin.videoconferenciaclaro.com/atomic-rhel7-nginx-php-fpm72

RUN curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo

# Verify ImageMagick version on https://imagemagick.org/download/linux/CentOS/x86_64/. It changes very often.
RUN microdnf clean all \
    && microdnf install -y zip unzip git zlib-devel libcurl-devel openssl-devel libxml2-devel rh-php72-php-devel pcre-devel yum gcc \
    && microdnf clean all \
    && curl -u ${NEXUS_USER}:${NEXUS_PASSWORD} https://nexus-admin.videoconferenciaclaro.com/repository/videoconferencia_claro/imagemagick/ImageMagick-libs-7.0.10-25.x86_64.rpm -O \
    && curl -u ${NEXUS_USER}:${NEXUS_PASSWORD} https://nexus-admin.videoconferenciaclaro.com/repository/videoconferencia_claro/imagemagick/ImageMagick-7.0.10-25.x86_64.rpm -O \
    && curl -u ${NEXUS_USER}:${NEXUS_PASSWORD} https://nexus-admin.videoconferenciaclaro.com/repository/videoconferencia_claro/imagemagick/ImageMagick-devel-7.0.10-25.x86_64.rpm -O \
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

# Install Composer
RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin/ --filename=composer

ADD ${GIT_PROJECT_NAME} /var/www/iam

WORKDIR /var/www/iam

RUN sed -i "s%chdir =.*%chdir = /var/www%g" /etc/opt/rh/rh-php72/php-fpm.d/www.conf \
    && sed -i "s%root /var.*%root /var/www/\$host/public;%g" /etc/nginx/nginx.conf \
    && sed -i "s%user  nginx;%user  root;%g" /etc/nginx/nginx.conf \
    && sed -i "s%listen.owner = nginx%listen.owner = root%g" /etc/opt/rh/rh-php72/php-fpm.d/www.conf \
    && sed -i "s%user = apache%user = root%g" /etc/opt/rh/rh-php72/php-fpm.d/www.conf \
    && sed -i "s%group = apache%group = root%g" /etc/opt/rh/rh-php72/php-fpm.d/www.conf \
    && sed -i "s%/opt/rh/rh-php72/root/usr/sbin/php-fpm --.*%/opt/rh/rh-php72/root/usr/sbin/php-fpm --nodaemonize --allow-to-run-as-root \\&%g" /sbin/docker-entrypoint.sh \
    && echo 'phpweb:x:1000:apache,nginx' >> /etc/group \
    && chown -R apache:phpweb /var/www \
    && chmod -R 755 /var/www/iam/storage \
    && composer dump-autoload --optimize \
    && composer install

RUN echo 'dXNlciAgcm9vdDsKd29ya2VyX3Byb2Nlc3NlcyAgMTsKI2Vycm9yX2xvZyAgL2Rldi9zdGRvdXQgd2FybjsKcGlkICAgICAgICAvdmFyL3J1bi9uZ2lueC5waWQ7CmV2ZW50cyB7ICAgIAogICAgd29ya2VyX2Nvbm5lY3Rpb25zICAxMDI0MDA7Cn0KaHR0cCB7ICAgIAogICAgaW5jbHVkZSAgICAgICAvZXRjL25naW54L21pbWUudHlwZXM7ICAgIAogICAgZGVmYXVsdF90eXBlICBhcHBsaWNhdGlvbi9vY3RldC1zdHJlYW07ICAgIAogICAgc2VydmVyX3Rva2VucyBvZmY7ICAgIAogICAgI2FjY2Vzc19sb2cgIC9kZXYvbnVsbDsgICAgCiAgICBzZW5kZmlsZSAgICAgICAgb247ICAgIAogICAgdGNwX25vcHVzaCAgICAgIG9uOyAgICAKICAgIHRjcF9ub2RlbGF5ICAgICBvbjsKCiAgICBzZXJ2ZXJfbmFtZXNfaGFzaF9idWNrZXRfc2l6ZSAgIDEyODsKICAgICMgU3RhcnQ6IFNpemUgTGltaXRzICYgQnVmZmVyIE92ZXJmbG93cyAjCiAgICBjbGllbnRfYm9keV9idWZmZXJfc2l6ZSAgICAgICAgIDFLOwogICAgY2xpZW50X2hlYWRlcl9idWZmZXJfc2l6ZSAgICAgICAxazsKICAgIGNsaWVudF9tYXhfYm9keV9zaXplICAgICAgICAgICAgNjRrOwogICAgbGFyZ2VfY2xpZW50X2hlYWRlcl9idWZmZXJzICAgICAxNiAxNms7CiAgICAjIEVORDogU2l6ZSBMaW1pdHMgJiBCdWZmZXIgT3ZlcmZsb3dzICMKCiAgICAjIERlZmF1bHQgdGltZW91dHMKICAgIGtlZXBhbGl2ZV90aW1lb3V0ICAgICAgICAgIDMwNXM7CiAgICBjbGllbnRfYm9keV90aW1lb3V0ICAgICAgICAgMTBzOwogICAgY2xpZW50X2hlYWRlcl90aW1lb3V0ICAgICAgIDEwczsKICAgIHNlbmRfdGltZW91dCAgICAgICAgICAgICAgICAyMHM7CiAgICBmYXN0Y2dpX2Nvbm5lY3RfdGltZW91dCAgICAgNjBzOwogICAgZmFzdGNnaV9zZW5kX3RpbWVvdXQgICAgICAgIDMwczsKICAgIGZhc3RjZ2lfcmVhZF90aW1lb3V0ICAgICAgICA2MHM7CiAgICAjCiAgICByZXNldF90aW1lZG91dF9jb25uZWN0aW9uICAgb247CgogICAgZ3ppcCAgb247CiAgICBnemlwX2Rpc2FibGUgIm1zaWU2IjsKICAgIGd6aXBfaHR0cF92ZXJzaW9uIDEuMTsKICAgIGd6aXBfYnVmZmVycyAzMiA4azsKICAgIGd6aXBfbWluX2xlbmd0aCAgMTAwMDsKICAgIGd6aXBfdHlwZXMgIHRleHQvcGxhaW4KICAgICAgICAgICAgdGV4dC9jc3MKICAgICAgICAgICAgdGV4dC9qYXZhc2NyaXB0CiAgICAgICAgICAgIHRleHQveG1sCiAgICAgICAgICAgIHRleHQveC1jb21wb25lbnQKICAgICAgICAgICAgYXBwbGljYXRpb24vamF2YXNjcmlwdAogICAgICAgICAgICBhcHBsaWNhdGlvbi9qc29uCiAgICAgICAgICAgIGFwcGxpY2F0aW9uL3htbAogICAgICAgICAgICBhcHBsaWNhdGlvbi9yc3MreG1sCiAgICAgICAgICAgIGZvbnQvdHJ1ZXR5cGUKICAgICAgICAgICAgZm9udC9vcGVudHlwZQogICAgICAgICAgICBhcHBsaWNhdGlvbi92bmQubXMtZm9udG9iamVjdAogICAgICAgICAgICBpbWFnZS9zdmcreG1sCiAgICAgICAgICAgIGltYWdlL3BuZwogICAgICAgICAgICBpbWFnZS9naWYKICAgICAgICAgICAgaW1hZ2UvanBlZwogICAgICAgICAgICBpbWFnZS9qcGc7CiAgICBwcm94eV9pbnRlcmNlcHRfZXJyb3JzICBvZmY7CiAgICAjIEJhcmUgcGhwIGV4ZWN1dGVyCiAgICAjCiAgICBzZXJ2ZXIgewogICAgICAgIGxpc3RlbiA4MCBkZWZhdWx0OwogICAgICAgIHJvb3QgL3Zhci93d3cvJGhvc3QvcHVibGljOwoKICAgICAgICBsb2NhdGlvbiB+IFwucGhwJCB7CiAgICAgICAgaWYgKCRyZXF1ZXN0X3VyaSB+IF4vaWFtKC4qKSQgKSB7CiAgICAgICAgICAgICAgICBzZXQgJHJlcXVlc3RfdXJsICQxOwogICAgICAgICAgICAgICAgfQogICAgICAgIGZhc3RjZ2lfc3BsaXRfcGF0aF9pbmZvIF4oLitcLnBocCkoLy4rKSQ7CiAgICAgICAgZmFzdGNnaV9wYXNzICAgICAgICAgICAgICAgIHVuaXg6L3Zhci9ydW4vcGhwLWZwbS5zb2NrOwogICAgICAgIGZhc3RjZ2lfaW5kZXggaW5kZXgucGhwOwogICAgICAgIGluY2x1ZGUgZmFzdGNnaV9wYXJhbXM7CiAgICAgICAgZmFzdGNnaV9wYXJhbSAgUkVRVUVTVF9VUkkgICAgICAgICRyZXF1ZXN0X3VybDsKICAgICAgICBmYXN0Y2dpX3BhcmFtIFNDUklQVF9GSUxFTkFNRSAvdmFyL3d3dy9pYW0vcHVibGljJGZhc3RjZ2lfc2NyaXB0X25hbWU7CiAgICAgICAgZmFzdGNnaV9wYXJhbSBSRU1PVEVfQUREUiAkaHR0cF94X2ZvcndhcmRlZF9mb3I7CgogICAgICAgIGZhc3RjZ2lfaW50ZXJjZXB0X2Vycm9ycyBvZmY7CiAgICAgICAgZmFzdGNnaV9idWZmZXJfc2l6ZSAxNms7CiAgICAgICAgZmFzdGNnaV9idWZmZXJzIDQgMTZrOwogICAgICAgIGZhc3RjZ2lfY29ubmVjdF90aW1lb3V0IDMwMDsKICAgICAgICBmYXN0Y2dpX3NlbmRfdGltZW91dCAzMDA7CiAgICAgICAgZmFzdGNnaV9yZWFkX3RpbWVvdXQgMzAwOwoKICAgICAgICB9CgoKICAgICAgICBsb2NhdGlvbiB+IC9pYW0vKC4qKSB7CiAgICAgICAgICAgIHJvb3QgL3Zhci93d3cvaWFtL3B1YmxpYzsKICAgICAgICAgICAgaW5kZXggaW5kZXguaHRtbCBpbmRleC5odG1sOwogICAgICAgICAgICB0cnlfZmlsZXMgJHVyaSAvJDEgL2luZGV4LnBocD8kcXVlcnlfc3RyaW5nOwogICAgICAgIH0KCiAgICAgICAgbG9jYXRpb24gfiBeL2ltYWdlcy8oLiopIHsKICAgICAgICAgICAgYWxpYXMgL3Zhci93d3cvaWFtL3B1YmxpYy9pbWFnZXMvJDE7CiAgICAgICAgfQogICAgfQp9Cg==' | base64 -d > /etc/nginx/nginx.conf

RUN rpm -Uvh http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm \
    && microdnf install newrelic-php5 \
    && NR_INSTALL_SILENT=1 newrelic-install install \
    && sed -i 's/newrelic.license.*/newrelic.license="85cfa808886e4fba9422a93711c331b4beb7NRAL"/g' /etc/opt/rh/rh-php72/php.d/newrelic.ini \
    && sed -i 's/newrelic.appname.*/newrelic.appname = "iam-php-prod"/g' /etc/opt/rh/rh-php72/php.d/newrelic.ini \
    && echo 'newrelic.distributed_tracing_enabled=true' >> /etc/opt/rh/rh-php72/php.d/newrelic.ini
