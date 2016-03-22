# Copyright 2016 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM debian:jessie

ENV GITHUB_BASEURL https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.2
ENV STORAGE_BASEURL https://storage.googleapis.com/kubernetes-release/release/v1.2.0

RUN set -eux &&\
  DEBIAN_FRONTEND=noninteractive apt-get update -y &&\
  DEBIAN_FRONTEND=noninteractive apt-get -yy -q \
    install \
    iptables \
    ethtool \
    ca-certificates \
    file \
    util-linux \
    socat \
    curl &&\
  DEBIAN_FRONTEND=noninteractive apt-get autoremove -y &&\
  DEBIAN_FRONTEND=noninteractive apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD $STORAGE_BASEURL/bin/linux/amd64/hyperkube /hyperkube
ADD $GITHUB_BASEURL/cluster/saltbase/salt/helpers/safe_format_and_mount /usr/share/google/safe_format_and_mount
ADD $GITHUB_BASEURL/cluster/saltbase/salt/generate-cert/make-ca-cert.sh /make-ca-cert.sh

COPY manifests /etc/kubernetes/manifests

# COPY master-multi.json /etc/kubernetes/manifests-multi/master.json
# COPY kube-proxy.json /etc/kubernetes/manifests-multi/kube-proxy.json
# COPY master.json /etc/kubernetes/manifests/master.json
# COPY etcd.json /etc/kubernetes/manifests/etcd.json
# COPY kube-proxy.json /etc/kubernetes/manifests/kube-proxy.json
COPY setup-files.sh /setup-files.sh

RUN set -eux &&\
  mkdir -p /etc/kubernetes/manifests-multi &&\
  mv /etc/kubernetes/manifests/master-multi.json /etc/kubernetes/manifests-multi/master.json &&\
  ln -s /etc/kubernetes/manifests/kube-proxy.json /etc/kubernetes/manifests-multi/kube-proxy.json &&\
  cp /usr/bin/nsenter /nsenter &&\
  chmod a+rx \
    /hyperkube \
    /usr/share/google/safe_format_and_mount \
    /setup-files.sh \
    /make-ca-cert.sh
