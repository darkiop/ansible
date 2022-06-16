#!/bin/bash

ssh pve01 -p 22 -l darkiop -t "sudo /usr/sbin/pvesm set --disable true odin-nfs-pve"
ssh pve01 -p 22 -l darkiop -t "sudo /usr/sbin/pvesm set --disable true odin-pbs-pve"

# EOF