#!/bin/bash

# Wrapper script for downloading and parsing GEO/SRA metadata for a single GSE
# series or a list of series (in a file), provided as first argument

# Check if an argument exists
if [ -z ${1+x} ]; then
    echo "ERROR: missing input parameters; aborting."
    echo "Please provide either a single GSE ID or a file containing the IDs"
    echo "to be queried as first argument to this script!"
    exit 1
fi

# Input
INPUT=$1

# Get the GEO metadata
echo "Querying GEO ..."
get_geo_metadata.R $INPUT -a

# Get the SRA metadata
echo "Querying SRA ..."
get_sra_metadata.sh

# Merge the two metadata files and order columns
echo "Merging GEO and SRA metadata ..."
merge_metadata.R

# Remove temporary files
rm geo_metadata.txt sra_metadata.txt
echo "Done."
