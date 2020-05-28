FROM centos:7

ENV SUMMARY="MongoDB NoSQL database server" \
    DESCRIPTION="MongoDB is a free and open-source \
cross-platform document-oriented database program. Classified as a NoSQL \
database program, MongoDB uses JSON-like documents with schemas. This \
container image contains programs to run mongod server."

ENV CONTAINER_SCRIPTS_PATH=/usr/share/mongod-scripts \
	MONGODB_DATADIR=/mongodb_data \
    MONGODB_LOGPATH=/mongodb_log \
    MONGODB_KEYFILE_PATH=/mongodb_data/keyfile

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="MongoDB 3.6" \
      io.openshift.expose-services="27017:mongodb" \
      io.openshift.tags="database,mongodb,mongodb-enterprise-36" \
      com.redhat.component="rh-mongodb36-container" \
      name="centos/mongodb-36-centos7" \
      usage="docker run -d -e MONGODB_ADMIN_PASSWORD=my_pass mongodb:latest" \
      version="1" \
      maintainer="MongoDB <juan.crossley@mongodb.com>"

COPY root /

# COPY mongodb-enterprise-server-3.6.10-1.el7.x86_64.rpm /opt/mongodb-enterprise-server-3.6.10-1.el7.x86_64.rpm
# COPY mongodb-enterprise-shell-3.6.10-1.el7.x86_64.rpm /opt/mongodb-enterprise-shell-3.6.10-1.el7.x86_64.rpm
# COPY mongodb-enterprise-mongos-3.6.10-1.el7.x86_64.rpm /opt/mongodb-enterprise-mongos-3.6.10-1.el7.x86_64.rpm
# COPY mongodb-enterprise-tools-3.6.10-1.el7.x86_64.rpm /opt/mongodb-enterprise-tools-3.6.10-1.el7.x86_64.rpm

ADD https://repo.mongodb.com/yum/redhat/7/mongodb-enterprise/3.6/x86_64/RPMS/mongodb-enterprise-server-3.6.10-1.el7.x86_64.rpm /opt/mongodb-enterprise-server-3.6.10-1.el7.x86_64.rpm
ADD https://repo.mongodb.com/yum/redhat/7/mongodb-enterprise/3.6/x86_64/RPMS/mongodb-enterprise-mongos-3.6.10-1.el7.x86_64.rpm /opt/mongodb-enterprise-mongos-3.6.10-1.el7.x86_64.rpm
ADD https://repo.mongodb.com/yum/redhat/7/mongodb-enterprise/3.6/x86_64/RPMS/mongodb-enterprise-tools-3.6.10-1.el7.x86_64.rpm /opt/mongodb-enterprise-tools-3.6.10-1.el7.x86_64.rpm 
ADD https://repo.mongodb.com/yum/redhat/7/mongodb-enterprise/3.6/x86_64/RPMS/mongodb-enterprise-shell-3.6.10-1.el7.x86_64.rpm /opt/mongodb-enterprise-shell-3.6.10-1.el7.x86_64.rpm 

RUN mkdir -p /mongodb_data && \ 
    mkdir -p /mongodb_log && \
    mkdir -p /var/run/mongodb && \
    chgrp -R 0 /var/run/mongodb && \
    chmod -R g+rwX /var/run/mongodb && \
    chgrp -R 0 /mongodb_data && \
    chmod -R g+rwX /mongodb_data && \
    chgrp -R 0 /mongodb_log && \
    chmod -R g+rwX /mongodb_log && \
    chmod 755 /etc/init.d/disable-transparent-hugepages && \
    chkconfig --add disable-transparent-hugepages && \
    yum update -y && \
    yum install -y gettext cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs libcurl lm_sensors-libs net-snmp net-snmp-agent-libs openldap openssl dos2unix && \
    rpm -ivh /opt/mongodb-enterprise-server-3.6.10-1.el7.x86_64.rpm && \
    rpm -ivh /opt/mongodb-enterprise-shell-3.6.10-1.el7.x86_64.rpm && \
    rpm -ivh /opt/mongodb-enterprise-mongos-3.6.10-1.el7.x86_64.rpm && \
    rpm -ivh /opt/mongodb-enterprise-tools-3.6.10-1.el7.x86_64.rpm && \
    yum clean all && \
    chmod -R g+x /usr/bin/run_mongod && \
    chgrp -R 0 /etc/mongod.conf && \
    chmod -R g+rwX /etc/mongod.conf && \
    dos2unix /usr/bin/container-entrypoint && \
    dos2unix /usr/bin/run_mongod

ENTRYPOINT ["container-entrypoint"]
CMD ["run_mongod"]
#CMD ["tail", "-f", "/dev/null"]

VOLUME ["/mongodb_data", "/mongodb_log"]
