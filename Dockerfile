FROM nginx:1.19.5 AS builder

RUN apt update \
    && apt install -y curl

RUN apt install -y build-essential \
    && curl -sL https://people.freebsd.org/~osa/ngx_http_redis-0.3.9.tar.gz | tar xz \ 
    && curl -sL https://github.com/openresty/redis2-nginx-module/archive/v0.15.tar.gz | tar xz \
    && curl -sL https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz | tar xz \
    && curl -sL https://www.zlib.net/zlib-1.2.11.tar.gz | tar xz \
    && curl -sL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar xz \
    && cd nginx-$NGINX_VERSION \
    && ./configure --with-compat --with-pcre=../pcre-8.43 --with-zlib=../zlib-1.2.11 \
         --add-dynamic-module=../redis2-nginx-module-0.15 \
         --add-dynamic-module=../ngx_http_redis-0.3.9 \
    && make \
    && make install

FROM nginx:1.19.5

COPY --from=builder /usr/local/nginx/modules/*.so /etc/nginx/modules/

RUN sed -i '1 i\load_module /etc/nginx/modules/ngx_http_redis_module.so;' /etc/nginx/nginx.conf \
    && sed -i '1 i\load_module /etc/nginx/modules/ngx_http_redis2_module.so;' /etc/nginx/nginx.conf \
    && sed -i '1 i\load_module /etc/nginx/modules/ngx_http_js_module.so;' /etc/nginx/nginx.conf 
