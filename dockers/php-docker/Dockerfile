from centos:centos7.5.1804

ENV GPG_KEYS 1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3

ENV PHP_VERSION 7.0.32
ENV PHP_URL="https://secure.php.net/get/php-7.0.32.tar.xz/from/this/mirror" PHP_ASC_URL="https://secure.php.net/get/php-7.0.32.tar.xz.asc/from/this/mirror"
ENV PHP_SHA256="ff6f62afeb32c71b3b89ecbd42950ef6c5e0c329cc6e1c58ffac47e6f1f883c4" PHP_MD5=""

RUN set -xe; \
	\
	fetchDeps=' \
		wget \
	'; \
	if ! command -v gpg > /dev/null; then \
		fetchDeps="$fetchDeps \
			dirmngr \
			gnupg \
		"; \
	fi; \
	yum update -y;\
	yum install -y $fetchDeps; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	wget -O php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	if [ -n "$PHP_MD5" ]; then \
		echo "$PHP_MD5 *php.tar.xz" | md5sum -c -; \
	fi; \
	\
	if [ -n "$PHP_ASC_URL" ]; then \
		wget -O php.tar.xz.asc "$PHP_ASC_URL"; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		done; \
		gpg --batch --verify php.tar.xz.asc php.tar.xz; \
		command -v gpgconf > /dev/null; \
		rm -rf "$GNUPGHOME"; \
	fi; \
	\
	yum clean all;

# dependencies required for running "phpize"
# (see persistent deps below)
ENV PHPIZE_DEPS \
		autoconf \
		file \
		gcc \
		gcc-c++ \ 
		make 

# persistent / runtime deps
RUN yum update -y && yum install -y \
		$PHPIZE_DEPS \
		ca-certificates \
		curl \
	&& yum clean all

COPY docker-php-source /usr/local/bin/

RUN set -eux; \
	\
	yum install -y epel-release \
	&& yum update -y \
	&& yum install -y \
		curl-devel \
		openssl-devel \
		libedit-devel \
		libsqlite3-devel \
		libssl-devel \
		libxml2-devel \
		zlib1g-devel \
		libjpeg-devel \
		libpng-devel \
		freetype-devel \
		libicu-devel \
		libmcrypt-devel \
		libxslt-devel \
		libmcrypt-devel \
	&& yum clean all; \
	\
	docker-php-source extract; \
	cd /usr/src/php7cache; \
	\
	./configure \
        --prefix=/usr/local/php7cache \
        --with-config-file-path=/usr/local/php7cache/etc \
        --with-config-file-scan-dir=/usr/local/php7cache/etc/php.d  \
        --enable-session \
        --with-fpm-user=www \
        --with-fpm-group=www \
        --enable-fpm \
        --enable-opcache \
        --enable-mysqlnd \
        --with-mysqli=mysqlnd \
        --with-pdo-mysql=mysqlnd \
        --with-iconv-dir=/usr/local \
        --with-freetype-dir \
        --with-jpeg-dir \
        --with-png-dir \
        --with-zlib \
        --with-libxml-dir=/usr \
        --enable-xml \
        --enable-bcmath \
        --enable-shmop \
        --enable-exif \
        --enable-sysvsem \
        --with-curl \
        --enable-mbregex \
        --enable-inline-optimization \
        --enable-mbstring \
        --with-mcrypt \
        --with-gd \
        --enable-gd-native-ttf \
        --with-openssl \
# https://github.com/docker-library/php/issues/439
        --with-mhash \
        \
        --enable-pcntl \
        --enable-sockets \
        --with-xmlrpc \
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
        --enable-ftp \
        \
        --enable-intl \
        --with-xsl \
        --with-gettext \
        --enable-zip \
        --enable-soap \
        --disable-ipv6 \
        --disable-debug \
# make sure invalid --configure-flags are fatal errors intead of just warnings
		--enable-option-checking=fatal \
	; \
	make -j "$(nproc)"; \
	make install; \
	find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; \
	make clean; \
	\
# https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
	cp -v php.ini-* "/usr/local/php7cache/etc/"; \
	install -v -m755  sapi/fpm/init.d.php-fpm  /etc/init.d/php-fpm; \
	\
	cd /; \
	docker-php-source delete; \
	\
	/usr/local/php7cache/bin/php --version; \
	\
# https://github.com/docker-library/php/issues/443
	/usr/local/php7cache/bin/pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc; \
	cp /usr/local/php7cache/etc/php-fpm.conf.default /usr/local/php7cache/etc/php-fpm.conf; \
	cp /usr/local/php7cache/etc/php-fpm.d/www.conf.default /usr/local/php7cache/etc/php-fpm.d/www.conf; \
	cp /usr/local/php7cache/etc/php.ini-production /usr/local/php7cache/etc/php.ini; 


RUN set -eux; \
	\
	cd /usr/src; \
	\
	wget http://pecl.php.net/get/mongodb-1.5.3.tgz; \
	\
	tar -zxf mongodb-1.5.3.tgz; \
	cd mongodb-1.5.3; \
	/usr/local/php7cache/bin/phpize; \
	./configure --with-php-config=/usr/local/php7cache/bin/php-config; \
	make; \
	make install; \
	make clean; \
	rm -fr mongodb-1.5.3.tgz; \
	rm -fr mongodb-1.5.3;

RUN set -eux; \
	\
	cd /usr/src; \
	\
	wget http://pecl.php.net/get/redis-3.0.0.tgz; \
	\
	tar -zxvf redis-3.0.0.tgz; \
	cd redis-3.0.0; \
	/usr/local/php7cache/bin/phpize; \
	./configure --with-php-config=/usr/local/php7cache/bin/php-config; \
	make; \
	make install; \
	make clean; \
	rm -fr redis-3.0.0.tgz; \
	rm -fr redis-3.0.0;

#RUN set -eux; \
#    \
#    yum install -y \
#        libmemcached-devel \
#    ; \
#    \
#    cd /usr/src; \
#    \
#    wget http://pecl.php.net/get/memcached-3.0.4.tgz; \
#    \
#    tar -zxvf memcached-3.0.4.tgz; \
#    cd memcached-3.0.4; \
#    /usr/local/php7cache/bin/phpize; \
#    ./configure --with-php-config=/usr/local/php7cache/bin/php-config; \
#    make; \
#    make install; \
#    make clean; \
#    rm -fr memcached-3.0.4.tgz; \
#    rm -fr memcached-3.0.4;

RUN set -eux; \
	\
	groupadd -r www; \
	\
	useradd -s /sbin/nologin -g www -r www;

COPY docker-php-entrypoint docker-php-start.sh /usr/local/bin/
RUN ["chmod", "+x", "/usr/local/bin/docker-php-start.sh"]

ENTRYPOINT ["docker-php-entrypoint"]
##<autogenerated>##
WORKDIR /dockerdata/www/html

EXPOSE 9000
CMD ["docker-php-start.sh"]
##</autogenerated>##

