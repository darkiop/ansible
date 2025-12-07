#!/bin/bash

ssh darkiop@pve01 bash -c "'sudo /usr/sbin/pvesm set --disable true nfs-odin'"
ssh darkiop@pve01 bash -c "'sudo /usr/sbin/pvesm set --disable true pbs-odin'"

# EOF