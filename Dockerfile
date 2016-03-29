FROM ubuntu:14.04

RUN echo "-------> Installing Java 8, Ansible, JQ & Httpie." \
 && apt-get update \
 && apt-get install -yq \
            software-properties-common \
            curl \
            unzip \
            wget \
 && apt-add-repository ppa:webupd8team/java \
 && apt-add-repository ppa:ansible/ansible \
 && apt-add-repository ppa:ubuntu-lxc/lxd-stable  \
 && apt-get update \
 && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
 && apt-get install -yq \
            ansible \
            oracle-java8-installer \
            jq \
            httpie \
            iptables \
            lxc \
            build-essential \
            fontconfig \
 && apt-get clean

 # grab gosu for easy step-down from root
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" \
 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture).asc" \
 && gpg --verify /usr/local/bin/gosu.asc \
 && rm /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu

# This will use the latest release
RUN wget -O /usr/local/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-latest \
 && chmod +x /usr/local/bin/docker \
 && groupadd docker

ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
ENV AGENT_DIR  /opt/buildAgent

RUN adduser --disabled-password --gecos "" teamcity \
 && sed -i -e "s/%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers \
 && usermod -a -G docker,sudo teamcity \
 && mkdir -p /data

EXPOSE 9090

VOLUME /var/lib/docker
VOLUME /data

ADD bin /usr/bin

# Install the magic wrapper.
ADD wrapdocker /usr/local/bin/wrapdocker

ADD docker-entry.sh /docker-entry.sh

ENTRYPOINT ["/docker-entry.sh"]
