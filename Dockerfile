# ib-keycloak
FROM  jboss/keycloak-postgres:latest

MAINTAINER Justin Davis <justinndavis@gmail.com>

ENV BUILDER_VERSION 1.0

LABEL io.k8s.description="Image for building Keycloak deployments" \
      io.k8s.display-name="Keycloak builder 1.0.0" \
      io.openshift.expose-services="8080:tcp" \
      io.openshift.tags="builder,1.0.0,keycloak,oauth,security" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"


#RUN sudo yum -y update
#RUN sudo yum -y install wget curl git
#RUN sudo yum clean all -y

#RUN mkdir -p /ib/appl
#WORKDIR /ib/appl

RUN mkdir -p /usr/libexec/s2i
COPY ./.s2i/bin/ /usr/libexec/s2i

#RUN chgrp -R 0 /ib/appl
#RUN chmod -R g+rw /ib/appl
#RUN find /ib/appl -type d -exec chmod g+x {} +

USER 1001

EXPOSE 8080

CMD ["/usr/libexec/s2i/usage"]