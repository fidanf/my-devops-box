#!/bin/bash -eu

INSTALL_DIR="/home/vagrant/awx"
CUSTOM_AWX_CONFIG=/vagrant/awx_inventory
VERSION=${version:-"16.0.0"}

if ! [ -x "$(command -v docker)" ] ; then
    echo "Docker needs to be installed before this script!"
    exit 1
fi

# check if ansible is installed
if ! [ -x "$(command -v ansible)" ] ; then
    echo "Ansible needs to be installed before this script!"
    exit 1
fi

if [ -f /home/vagrant/.devops-features/awx ] ; then
    echo "AWX was already installed. Skipping..."
    exit 0
fi

# install dependencies
apt-get install -yq python3-pip
pip install --upgrade --ignore-installed docker-compose docker

# download release from github
wget -qO /tmp/awx.tar.gz https://github.com/ansible/awx/archive/${VERSION}.tar.gz
mkdir -p ${INSTALL_DIR}
tar -C ${INSTALL_DIR} -xzf /tmp/awx.tar.gz --strip-components 1

# import custom inventory if present
if [ -f ${CUSTOM_AWX_CONFIG} ] ; then
    cp ${CUSTOM_AWX_CONFIG} ${INSTALL_DIR}/installer/inventory
fi

# launch AWX installation playbook
echo "==> AWX version $(cat $INSTALL_DIR/VERSION) is going to be installed..."
pushd ${INSTALL_DIR}/installer
su vagrant -c 'ansible-playbook -i inventory install.yml'
popd

# "tag" feature as installed
echo "==> Refresh homedir permissions"
touch /home/vagrant/.devops-features/awx

# refresh permissions
chown -R vagrant:vagrant /home/vagrant
