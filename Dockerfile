FROM centos:centos7

RUN \
  yum clean all && \
  yum install -y docker && \
  yum list installed | awk 'NR >2 {print $1}' >/tmp/installed.pkg && \
  cat <<EOF > /etc/yum.repos.d/kubernetes.repo \
[kubernetes] \
name=Kubernetes \
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 \
enabled=1 \
gpgcheck=1 \
repo_gpgcheck=1 \
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg \
EOF && \
  yum install -y kubelet kubeadm kubectl && \
  mkdir /data && \
  cd /data && \
  cat /tmp/installed.pkg | while read line; do \
  yumdownloader $line \
  done && \
  yum install -y createrepo && \
  createrepo .

FROM nginx:alpine
COPY --from=0 /data /data
RUN echo "server {autoindex off; server_name localhost; location ~ ^/$ {return 200;} location ~ ^.*/$ {return 404;} location / { root /data; default_type application/octet-stream; add_header Content-Disposition 'attachment'; types {}}}" > /etc/nginx/conf.d/default.conf
