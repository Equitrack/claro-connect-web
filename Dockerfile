FROM nexus-admin.videoconferenciaclaro.com/vc-usuarios-php-base:latest

WORKDIR /var/www/claro-connect-usuarios

RUN mkdir -p /var/php70/storage/{cache,logs} \
    && chown -R 48 /var/php70/storage \
    && rm -rf /var/www/claro-connect-usuarios/storage \
    && composer dump-autoload --optimize \
    && composer install \
    && composer update \
    && ln -s /var/php70/storage /var/www/claro-connect-usuarios/storage \
    && NR_INSTALL_SILENT=1 newrelic-install install \
    && sed -i 's/newrelic.license.*/newrelic.license="85cfa808886e4fba9422a93711c331b4beb7NRAL"/g' /etc/opt/rh/rh-php70/php.d/newrelic.ini \
    && sed -i 's/newrelic.appname.*/newrelic.appname = "usuarios-php-prod"/g' /etc/opt/rh/rh-php70/php.d/newrelic.ini \
    && echo 'newrelic.distributed_tracing_enabled=true' >> /etc/opt/rh/rh-php70/php.d/newrelic.ini
