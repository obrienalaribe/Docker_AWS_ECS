FROM amazonlinux:latest
MAINTAINER O'Brien Alaribe <obrien.alaribe@manticpoint.com>


# Set environment variables and default password for user 'admin'
ENV GLASSFISH_PKG=glassfish-4.1.1-web.zip \
    GLASSFISH_URL=http://download.oracle.com/glassfish/4.1.1/release/glassfish-4.1.1-web.zip \
    GLASSFISH_HOME=/glassfish4 \
    PATH=$PATH:/glassfish4/bin \
    PASSWORD=glassfish

# Copy and Install packages
# COPY ijet.war /tmp


# Install packages, download and extract GlassFish
# Setup password file
# Enable DAS
RUN yum update -y && \
    yum install -y unzip wget vim java-1.8.0-openjdk-devel procps lsof iputils nfs-utils && \
    echo "--- Setting up Java 8 ---" && \
    mkdir -p /opt/log && \
    wget --no-check-certificate $GLASSFISH_URL && \
    unzip -o $GLASSFISH_PKG && \
    rm -f $GLASSFISH_PKG && \
    echo "--- Setup the password file ---" && \
    echo "AS_ADMIN_PASSWORD=" > /tmp/glassfishpwd && \
    echo "AS_ADMIN_NEWPASSWORD=${PASSWORD}" >> /tmp/glassfishpwd  && \
    echo "--- Enable DAS, change admin password, and secure admin access ---" && \
    asadmin --user=admin --passwordfile=/tmp/glassfishpwd change-admin-password --domain_name domain1 && \
    asadmin start-domain && \
    echo "AS_ADMIN_PASSWORD=${PASSWORD}" > /tmp/glassfishpwd && \
    asadmin --user=admin --passwordfile=/tmp/glassfishpwd enable-secure-admin && \
    asadmin --user=admin stop-domain && \
    rm /tmp/glassfishpwd && \
    mv /tmp/stream-receiver-sabre.war /glassfish4/glassfish/domains/domain1/autodeploy

# Ports being exposed
EXPOSE 4848 8080 8181

# Start asadmin console and the domain
CMD ["asadmin", "start-domain", "-v"]
