#!/bin/bash
# This script generates a YAML file with Pi-hole ad sources from a list of URLs

# Input file containing URLs
input_file="generate_pihole_ad_sources-input.txt"

# Output YAML file
output_file="generate_pihole_ad_sources-output.yaml"

# Initialize YAML file with the header
printf "pihole_ad_sources:\n" >"${output_file}"

# Initialize ID counter
id_counter=1

# Read each line from the input file
while IFS= read -r url; do
    # Trim trailing spaces from the URL
    url=$(echo "$url" | sed 's/[[:space:]]*$//')

    # Add entry to the YAML file
    printf "  - id: %d\n" "${id_counter}" >>"${output_file}"
    printf "    address: %s\n" "${url}" >>"${output_file}"
    printf "    enabled: true\n" >>"${output_file}"
    printf "    comment: ansible adlist\n" >>"${output_file}"

    # Increment the ID counter
    id_counter=$((id_counter + 1))
done <"${input_file}"

# Output the generated YAML file
echo "Generated ${output_file} with $((id_counter - 1)) entries."
