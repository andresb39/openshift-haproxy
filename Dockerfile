FROM andresb39/haproxycentos:v3

ADD ./cfg_files/cli /usr/bin/cli
ADD ./cfg_files/haproxy.cfg /etc/haproxy/haproxy.cfg
COPY licenses /licenses

COPY start-standalone /etcd/
RUN chmod +x /etcd/start-standalone

COPY start-local-cluster /etcd/
RUN chmod +x /etcd/start-local-cluster

COPY ./cfg_files/etcd.conf /etc/etcd/etcd.conf

EXPOSE 5432 7000 2379 2380 80

# CMD ["etcd"]

USER 10001

#ENTRYPOINT ["/usr/local/sbin/haproxy", "-W", "-f", "/etc/haproxy/haproxy.cfg"]