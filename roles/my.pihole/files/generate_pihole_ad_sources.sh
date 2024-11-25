#!/bin/bash

# Input file containing URLs
input_file="generate_pihole_ad_sources-input.txt"

# Output YAML file
output_file="generate_pihole_ad_sources-output.yaml"

# Initialize YAML file with the header
echo "pihole_ad_sources:" >"${output_file}"

# Initialize ID counter
id_counter=1

# Read each line from the input file
while IFS= read -r url; do
	# Add entry to the YAML file
	# trunk-ignore(shellcheck/SC2129)
	echo "  - id: ${id_counter}" >>"${output_file}"
	echo "    address: ${url}" >>"${output_file}"
	echo "    enabled: true" >>"${output_file}"
	echo "    comment: ansible adlist" >>"${output_file}"

	# Increment the ID counter
	id_counter=$((id_counter + 1))
done <"${input_file}"

# Output the generated YAML file
echo "Generated ${output_file} with $((id_counter - 1)) entries."
