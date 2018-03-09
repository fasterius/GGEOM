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

# GEO metadata ----------------------------------------------------------------

# Run GEO metadata R script
echo "Querying GEO ..."
geo_metadata.R $INPUT geo_metadata.txt -a

# SRA metadata ----------------------------------------------------------------

# Initialize file to get header (SRP ID is arbitrary)
echo "Querying SRA ..."
esearch -db sra -query SRP066982 \
    | efetch -format runinfo \
    | tr ',' '\t' \
    | head -1 \
    | sed 's/Run/SRR/g' \
        > sra_metadata.txt

# Get runinfo for each SRP ID in file
SRPCOL=$(head -1 geo_metadata.txt | xargs -n 1 | nl | grep "SRP" | cut -f 1)
for SRP in $(tail -n +2 geo_metadata.txt | cut -f $SRPCOL | sort | uniq); do

    # Query SRA and add runinfo to file
    echo "Fetching sequencing data for $SRP ..."
    esearch -db sra -query "$SRP" < /dev/null \
        | efetch -format runinfo \
        | tr ',' '\t' \
        | tail -n +2 \
        | grep -vw ReleaseDate \
        | grep -v -e '^[[:space:]]*$' \
            >> sra_metadata.txt
done

# Merge metadata --------------------------------------------------------------

# Merge the two metadata files and order columns
echo "Merging GEO and SRA metadata ..."
merge_metadata.R

# Remove temporary files
rm geo_metadata.txt sra_metadata.txt
echo "Done."
