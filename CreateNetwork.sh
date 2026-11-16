#!/usr/bin/env bash
docker network create -d bridge GroupNetwork --subnet=172.20.0.0/16 --gateway=172.20.0.1
