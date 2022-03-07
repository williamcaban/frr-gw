# podman build -t quay.io/wcaban/frr -f Containerfile
# podman tag quay.io/wcaban/frr:latest quay.io/wcaban/frr:$(date +%y%m%d)
# podman push quay.io/wcaban/frr:latest
# podman push quay.io/wcaban/frr:$(date +%y%m%d)
FROM quay.io/centos/centos:stream9

RUN dnf install --setopt=tsflags=nodocs -y \
    iproute bind-utils iputils net-tools procps \
    frr \
    haproxy \
    iperf3 \
    tcpdump \
    && dnf clean all \
    && rm -fr /var/cache/dnf

# Install latest OCP/K8s client
RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar -xzf - -C /usr/local/bin

LABEL io.k8s.display-name="FRR Router" \
    io.k8s.description="FRR Container with troubleshooting tools" \
    io.openshift.tags="frr,iproute,tcpdump"

ENTRYPOINT /bin/bash -c "sleep infinity"
