#!/bin/bash

#ssh darkiop@pve01 bash -c "'sudo /usr/sbin/pvesm set --disable false nfs-odin'"
ssh darkiop@pve01 bash -c "'sudo /usr/sbin/pvesm set --disable false pbs-odin'"

# EOF