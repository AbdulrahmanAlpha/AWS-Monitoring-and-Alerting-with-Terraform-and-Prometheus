#!/bin/bash

wget https://github.com/prometheus/prometheus/releases/download/v2.33.1/prometheus-2.33.1.linux-amd64.tar.gz
tar xfz prometheus-2.33.1.linux-amd64.tar.gz
cd prometheus-2.33.1.linux-amd64/

./prometheus --config.file=prometheus.yml