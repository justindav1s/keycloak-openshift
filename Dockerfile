# ib-keycloak
FROM  centos

MAINTAINER Justin Davis <justinndavis@gmail.com>

ENV BUILDER_VERSION 1.0
ENV KEYCLOAK_VERSION 2.2.0.Final
ENV JBOSS_HOME /ib/appl/keycloak
# Enables signals getting passed from startup script to JVM
# ensuring clean shutdown when container is stopped.
ENV LAUNCH_JBOSS_IN_BACKGROUND 1

LABEL io.k8s.description="Image for building keycloak deployments" \
      io.k8s.display-name="Keycloak builder 1.0.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,1.0.0,keycloaok,iberia,http" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"


RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
RUN yum -y install wget curl java-1.8.0-openjdk-devel git
RUN yum clean all -y

RUN mkdir -p /ib/appl
WORKDIR /ib/appl

RUN cd /ib/appl/ && curl -L https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz | tar zx && mv /ib/appl/keycloak-$KEYCLOAK_VERSION /ib/appl/keycloak

ADD scripts/docker-entrypoint.sh /ib/appl/

RUN cd /ib/appl/ && curl -L http://central.maven.org/maven2/net/sf/saxon/Saxon-HE/9.7.0-8/Saxon-HE-9.7.0-8.jar && mv /ib/appl/Saxon-HE-9.7.0-8.jar /ib/appl/saxon.jar

ADD scripts/setLogLevel.xsl /ib/appl/keycloak/
RUN java -jar /ib/appl/saxon.jar -s:/ib/appl/keycloak/standalone/configuration/standalone.xml -xsl:/ib/appl/keycloak/setLogLevel.xsl -o:/ib/appl//keycloak/standalone/configuration/standalone.xml

ADD scripts/changeDatabase.xsl /ib/appl/keycloak/
RUN java -jar /ib/appl/saxon.jar -s:/ib/appl/keycloak/standalone/configuration/standalone.xml -xsl:/ib/appl/keycloak/changeDatabase.xsl -o:/ib/appl/keycloak/standalone/configuration/standalone.xml; java -jar /usr/share/java/saxon.jar -s:/ib/appl/keycloak/standalone/configuration/standalone-ha.xml -xsl:/ib/appl/keycloak/changeDatabase.xsl -o:/ib/appl/keycloak/standalone/configuration/standalone-ha.xml; rm /ib/appl/keycloak/changeDatabase.xsl
RUN mkdir -p /ib/appl/keycloak/modules/system/layers/base/org/postgresql/jdbc/main; cd /ib/appl/keycloak/modules/system/layers/base/org/postgresql/jdbc/main; curl -O http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1102-jdbc3/postgresql-9.3-1102-jdbc3.jar
ADD scripts/module.xml /ib/appl/keycloak/modules/system/layers/base/org/postgresql/jdbc/main/

RUN mkdir -p /usr/libexec/s2i
COPY ./.s2i/bin/ /usr/libexec/s2i

RUN chgrp -R 0 /ib/appl
RUN chmod -R g+rw /ib/appl
RUN find /ib/appl -type d -exec chmod g+x {} +

USER 1001

EXPOSE 8080

#CMD ["/usr/libexec/s2i/usage"]