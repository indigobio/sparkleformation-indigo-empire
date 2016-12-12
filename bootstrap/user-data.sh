#!/bin/bash -e

ANSIBLE_VERSION=${ANSIBLE_VERSION:-2.2.0.0-1ppa}

sudo -H apt-get -qq update

# Install python prerequisites
sudo -H DEBIAN_FRONTEND=noninteractive apt-get -qq install curl python-setuptools python-pip python-lockfile unzip wget software-properties-common
sudo -H DEBIAN_FRONTEND=noninteractive apt-get -qq install --reinstall ca-certificates

# Install AWS tools
sudo -H pip install --upgrade pip
sudo -H pip install --timeout=60 s3cmd
sudo -H easy_install -q https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz

curl -sL https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o /tmp/awscli-bundle.zip
unzip -d /tmp /tmp/awscli-bundle.zip
sudo -H /tmp/awscli-bundle/install -i /opt/aws -b /usr/local/bin/aws
rm -rf /tmp/awscli-bundle*

# Install ansible
sudo -H apt-add-repository -y ppa:ansible/ansible
sudo -H apt-get -qq update
sudo -H apt-get -qq install ansible=${ANSIBLE_VERSION}~`lsb_release -s -c`

sudo -H mkdir -m 0777 -p /etc/ansible-local
