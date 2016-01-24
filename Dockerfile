FROM centos:7
MAINTAINER Madalin Ignisca <madalin.ignisca@gmail.com>
ENV nginx_version=1.8.0
RUN yum -y update \
  && yum install -y wget unzip gcc make pcre-devel openssl-devel \
  && yum clean all
WORKDIR /usr/local/src
RUN wget http://nginx.org/download/nginx-1.8.0.tar.gz \
  && tar zxf nginx-1.8.0.tar.gz
RUN wget https://github.com/vozlt/nginx-module-vts/archive/v0.1.8.zip \
  && unzip v0.1.8.zip
WORKDIR /usr/local/src/nginx-1.8.0
RUN ./configure --prefix=/usr/local/etc/nginx \
  --sbin-path=/usr/local/sbin/nginx \
  --conf-path=/usr/local/etc/nginx/nginx.conf \
  --error-log-path=/dev/stderr \
  --http-log-path=/dev/stdout \
  --pid-path=/usr/local/var/run/nginx.pid \
  --lock-path=/usr/local/var/run/nginx.lock \
  --http-client-body-temp-path=/usr/local/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/usr/local/var/cache/nginx/proxy_temp \
  --http-fastcgi-temp-path=/usr/local/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/usr/local/var/cache/nginx/uwsgi_temp \
  --http-scgi-temp-path=/usr/local/var/cache/nginx/scgi_temp \
  --user=nginx \
  --group=nginx \
  --with-http_ssl_module \
  --with-http_realip_module \
  --with-http_addition_module \
  --with-http_sub_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_random_index_module \
  --with-http_secure_link_module \
  --with-http_stub_status_module \
  --with-http_auth_request_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-file-aio \
  --with-http_spdy_module \
  --with-ipv6 \
  --add-module=/usr/local/src/nginx-module-vts-0.1.8
RUN make && make install
# clean and shrink the image
RUN yum remove -y wget unzip gcc make pcre-devel openssl-devel \
  cpp glibc-devel glibc-headers kernel-headers keyutils-libs-devel \
  krb5-devel libcom_err-devel libselinux-devel libsepol-devel libverto-devel \
  zlib-devel \
  && yum clean all \
  && rm -rf /usr/local/src/*
RUN useradd -M -s /sbin/nologin nginx \
  && mkdir -p /usr/local/var/cache/nginx \
  && chown nginx:nginx /usr/local/var/cache/nginx
VOLUME ["/usr/local/var/cache/nginx"]
EXPOSE 80 443
CMD ["/usr/local/sbin/nginx", "-g", "daemon off;"]
