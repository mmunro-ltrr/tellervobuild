FROM maven:3.5-jdk-8 as debbuilder

RUN set -e \
  && git clone https://github.com/ltrr-arizona-edu/tellervo.git \
  && cd tellervo/Libraries \
  && mvn install:install-file -DgroupId=gov.nasa.worldwind -DartifactId=worldwindjava-tellervo -Dversion=2.0.0 -Dpackaging=jar -Dfile=worldwindjava-tellervo-2.0.0.jar \
  && cd .. \
  && mvn package -P binaries

VOLUME /root/.m2


FROM mmunro/bloatstack:0.1.2-xenial

ENV SERVER_NAME=tellervo

COPY --from=debbuilder /tellervo/target/binaries/server/1.3.3/Linux/tellervo-server-1.3.3.deb /tmp

RUN set -e \
  && adduser --disabled-password --gecos '' tellervo \
  && adduser tellervo sudo \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo "ServerName ${SERVER_NAME}" >> /etc/apache2/conf-enabled/servername.conf \
  && dpkg --install /tmp/tellervo-server-1.3.3.deb \
  && tellervo-server --auto-configure

# Setup Supervisord to run Apache and Postgres
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Ports to expose
EXPOSE 80

WORKDIR /var/www/tellervo
VOLUME /var/lib/postgresql/data

CMD ["/usr/bin/supervisord"]