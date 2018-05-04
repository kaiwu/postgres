FROM postgres:10.3-alpine
MAINTAINER WU KAI <kai.wu@goodbaby.com>

RUN sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories \
    && echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk upgrade --update-cache --available \
    && apk add --update \
        git \
        curl \
        postgis@testing \
        postgresql-plpython2 \
        build-base \
        perl \
        python2-dev \
        py2-pip \
        py2-cffi \
        py-boto \
        py2-asn1crypto \
    && pip install -U pip appdirs pgxnclient \
    && pgxn install multicorn \
    && pgxn install pgtap \
    && pgxn install plv8 \
    && cd / \
    && apk del --purge build-base \
    && rm -rf /var/cache/apk/*

VOLUME /var/lib/postgresql/data
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 5432
CMD ["postgres"]
