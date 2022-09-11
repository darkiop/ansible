#!/bin/bash

ssh darkiop@pve01 bash -c "'sudo /usr/sbin/pvesm set --disable false odin-nfs-pve'"
ssh darkiop@pve01 bash -c "'sudo /usr/sbin/pvesm set --disable false odin-pbs-pve'"

# EOF