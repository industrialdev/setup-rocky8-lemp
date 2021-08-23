#!/bin/bash

sudo yum -y install unzip wget && wget https://github.com/industrialdev/setup-rocky8-lemp/archive/master.zip && unzip master.zip && cd setup-rocky8-lemp-master && source setup_rocky_server.sh
