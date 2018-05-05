FROM postgres:v8
MAINTAINER WU KAI <kai.wu@goodbaby.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories \
    && echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk upgrade --update-cache --available \
    && apk add --update \
        curl \
        linux-headers \
        postgis@testing \
        postgresql-plpython2 \
        build-base \
        perl \
        python2-dev \
        py2-pip \
    && pip install -U pip pgxnclient pg_activity pgcli \
    && pgxn install multicorn \
    && pgxn install pgtap \
    && cp /usr/local/v8/lib/* /usr/local/lib/ \
    && cd /usr/lib/postgresql && cp address_standardizer-2.4.so plpython2.so postgis* rtpostgis-2.4.so /usr/local/lib/postgresql/ \
    && cd /usr/share/postgresql/extension && cp postgis* address_standardizer* plpython* /usr/local/share/postgresql/extension/ \
    && cd /tmp && pgxn download plv8 && unzip plv8-2.3.3.zip && cd plv8-2.3.3/ \
    && V8_SRCDIR=/usr/local/v8 make -f Makefile.shared \
    && V8_SRCDIR=/usr/local/v8 make -f Makefile.shared install \
    && curl -sSL http://s3.ci.goodbaby.com/postgres/v0.1.1.tar.gz | tar -xvzC /tmp/ \
    && cd /tmp/pgjwt \
    && make install \
    && cd / \
    && apk del --purge build-base \
    && rm -rf /tmp/pgjwt /tmp/plv8-2.3.3 /tmp/plv8-2.3.3.zip \
    && rm -rf /var/cache/apk/*

VOLUME /var/lib/postgresql/data
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 5432
CMD ["postgres"]
