 #!/bin/bash

# thor
ssh root@192.168.1.1 "arp -s 10.1.0.2 0c:9d:92:84:86:49"

# thor25
ssh root@192.168.1.1 "arp -s 192.168.1.42 8c:0e:60:d0:d9:cf"

# odin
ssh root@192.168.1.1 "arp -s 192.168.1.70 90:09:d0:0f:8e:0f"

# pve01
ssh root@192.168.1.1 "arp -s 192.168.1.71 1c:69:7a:02:5e:3f"

# pve02
ssh root@192.168.1.1 "arp -s 192.168.1.72 1c:69:7a:62:9b:95"