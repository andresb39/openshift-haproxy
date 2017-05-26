FROM registry.access.redhat.com/rhel7
MAINTAINER Dinko Korunic <dkorunic@haproxy.com>

LABEL name="haproxytech/haproxy" \
      vendor="HAProxy" \
      version="1.7.5" \
      release="1"

ENV HAPROXY_BRANCH 1.7
ENV HAPROXY_MINOR 1.7.5
ENV HAPROXY_MD5 ed84c80cb97852d2aa3161ed16c48a1c
ENV HAPROXY_SRC_URL http://www.haproxy.org/download

ENV HAPROXY_UID haproxy
ENV HAPROXY_GID haproxy

RUN yum clean all && yum-config-manager --disable \* &> /dev/null && \
    yum-config-manager --enable rhel-7-server-rpms,rhel-7-server-optional-rpms &> /dev/null && \
    yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
    yum -y install --setopt=tsflags=nodocs gcc make openssl-devel pcre-devel zlib-devel tar curl socat && \
    curl -sfSL "$HAPROXY_SRC_URL/$HAPROXY_BRANCH/src/haproxy-$HAPROXY_MINOR.tar.gz" -o haproxy.tar.gz && \
    echo "$HAPROXY_MD5  haproxy.tar.gz" | md5sum -c - && \
    groupadd "$HAPROXY_GID" && \
    useradd -g "$HAPROXY_GID" "$HAPROXY_UID" && \
    mkdir -p /tmp/haproxy && \
    tar -xzf haproxy.tar.gz -C /tmp/haproxy --strip-components=1 && \
    rm -f haproxy.tar.gz && \
    make -C /tmp/haproxy TARGET=linux2628 CPU=generic USE_PCRE=1 USE_REGPARM=1 USE_OPENSSL=1 \
                            USE_ZLIB=1 USE_TFO=1 USE_LINUX_TPROXY=1 \
                            all install-bin install-man && \
    ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy && \
    mkdir -p /var/lib/haproxy && \
    rm -rf /tmp/haproxy && \
    yum remove -y gcc make && \
    yum clean all

ADD ./cfg_files/cli /usr/bin/cli
ADD ./cfg_files/haproxy.cfg /etc/haproxy/haproxy.cfg

EXPOSE 80 443

CMD ["/usr/local/sbin/haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
