#!/bin/bash

# URL of the file to download
url="https://raw.githubusercontent.com/RPiList/specials/refs/heads/master/Blocklisten.md"

# Download the file, remove all comments (lines starting with #), lines containing ```, empty lines, and lines with only spaces
curl -s $url | sed '/^#/d; /```/d; /^\s*$/d' > generate_pihole_ad_sources-input.txt
