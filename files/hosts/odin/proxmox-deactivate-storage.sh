#!/bin/bash

ssh darkiop@pve01 bash -c "'sudo /usr/sbin/pvesm set --disable true odin-nfs-pve'"
ssh darkiop@pve01 bash -c "'sudo /usr/sbin/pvesm set --disable true odin-pbs-pve'"

# EOF