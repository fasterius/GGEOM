#!/bin/bash

# Wrapper script for downloading and parsing GEO/SRA metadata for a single GSE
# series or a list of series (in a file), provided as first argument

# Check if first and second argument exists
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
geo_metadata.R -a $INPUT tmp

# SRA metadata ----------------------------------------------------------------

# Initialize file to get header (SRP ID is arbitrary)
echo "Querying SRA ..."
esearch -db sra -query SRP066982 \
    | efetch -format runinfo \
    | tr ',' '\t' \
    | head -1 \
    | sed 's/Run/SRR/g' \
        > tmp2

# Get runinfo for each SRP ID in file
SRPCOL=$(head -1 tmp | tr '\t' '\n' | nl | grep "SRP" | cut -f 1)
for SRP in $(tail -n +2 tmp | cut -f $SRPCOL | sort | uniq); do

    # Query SRA and add runinfo to file
    esearch -db sra -query "$SRP" < /dev/null \
        | efetch -format runinfo \
        | tr ',' '\t' \
        | tail -n +2 \
        | grep -vw ReleaseDate \
        | grep -v -e '^[[:space:]]*$' \
            >> tmp2
done

# Merge metadata --------------------------------------------------------------

# Merge the two metadata files
echo "Merging metadata ..."
overlaps.R tmp,tmp2 tmp3 -c GSM,SampleName

# Reorder columns
paste \
    <(gawk -F '\t' -v OFS='\t' \
        '{print $2,$1,$3,$35,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$38,$42}' tmp3 \
        | sort -k 1) \
    <(cat tmp3 | cut -f 2,14-16,18-34,36,37,39-41,43- \
        | sort -k 1) \
    > metadata.txt

# Remove temporary files
rm tmp tmp2 tmp3
echo "Done."
