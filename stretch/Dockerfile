FROM maven:3.5-jdk-8 AS pljavabuilder

RUN set -e \
  && apt-get update \
  && apt-get install -y \
    g++ \
    libkrb5-dev \
    libssl-dev \
    postgresql-server-dev-9.6 \
  && rm -r /var/lib/apt/lists/* \
  && git clone https://github.com/tada/pljava.git \
  && cd pljava \
  && git checkout REL1_5_STABLE \
  && mvn clean install -Pwnosign

FROM maven:3.5-jdk-8 AS debbuilder

COPY --from=pljavabuilder /pljava/pljava-packaging/target/pljava-pg9.6-amd64-Linux-gpp.jar /tmp

COPY control_dir_for_deb_build96.patch /tmp/

RUN set -e \
  && git clone https://github.com/ltrr-arizona-edu/tellervo.git \
  && cd tellervo \
  && git checkout d0be4ba710f1ffba5686c03a837102f9494d6ce1 \
  && cd Libraries \
  && mvn install:install-file -DgroupId=gov.nasa.worldwind -DartifactId=worldwindjava-tellervo -Dversion=2.0.0 -Dpackaging=jar -Dfile=worldwindjava-tellervo-2.0.0.jar \
  && cd .. \
  && git apply --whitespace=fix /tmp/control_dir_for_deb_build96.patch \
  && cp /tmp/pljava-pg9.6-amd64-Linux-gpp.jar Native/BuildResources/LinBuild \
  && mvn package -P binaries


FROM mmunro/bloatstack:0.1.3-stretch

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
