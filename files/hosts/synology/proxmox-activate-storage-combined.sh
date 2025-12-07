#!/bin/bash

if [[ ${HOSTNAME} == odin ]]; then
	ssh darkiop@pve01 bash -c "'sudo /usr/sbin/pvesm set --disable false pbs-odin'"
elif [[ ${HOSTNAME} == freya ]]; then
	ssh darkiop@pve01 bash -c "'sudo /usr/sbin/pvesm set --disable false pbs-freya'"
else
	exit 1
fi
