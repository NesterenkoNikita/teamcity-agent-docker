FROM java:8

# This will use the latest release
RUN wget -O /usr/local/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-latest
RUN chmod +x /usr/local/bin/docker
ADD 10_wrapdocker.sh /etc/my_init.d/10_wrapdocker.sh
RUN groupadd docker

RUN apt-get update
RUN apt-get install -y unzip iptables lxc build-essential fontconfig sudo

ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
ENV AGENT_DIR  /opt/buildAgent

# Check install and environment
ADD 00_checkinstall.sh /etc/my_init.d/00_checkinstall.sh

RUN adduser --disabled-password --gecos "" teamcity
RUN sed -i -e "s/%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers
RUN usermod -a -G docker,sudo teamcity
RUN mkdir -p /data

EXPOSE 9090

VOLUME /var/lib/docker
VOLUME /data

# Install ansible
RUN echo "===> Installing python and supporting tools..."  && \
    apt-get update  && \
    DEBIAN_FRONTEND=noninteractive         \
    apt-get install -y                     \
        python python-yaml            \
        curl gcc python-pip python-dev  && \
    \
    \
    echo "===> Installing Ansible..."   && \
    pip install ansible                 && \
    \
    \
    echo "===> Removing unused APT resources..."                  && \
    apt-get -f -y --auto-remove remove gcc python-pip python-dev  && \
    apt-get clean                                                 && \
    rm -rf /var/lib/apt/lists/*  /tmp/*                           && \
    \
    \
    echo "===> Adding hosts for convenience..."        && \
    mkdir -p /etc/ansible                              && \
    echo 'localhost' > /etc/ansible/hosts

ADD service /etc/service
ADD bin /usr/bin
