#!/bin/bash

# Download SRA metadata using the Entrez E-Utilities

# Input file
INPUT="geo_metadata.txt"

# Initialize file to get header (the SRP ID is arbitrary)
esearch -db sra -query SRP066982 \
    | efetch -format runinfo \
    | tr ',' '\t' \
    | head -1 \
    | sed 's/Run/SRR/g' \
        > sra_metadata.txt

# Get runinfo for each SRP ID in file
SRPCOL=$(head -1 "$INPUT" | xargs -n 1 | nl | grep "SRP" | cut -f 1)
for SRP in $(tail -n +2 "$INPUT" | cut -f $SRPCOL | sort | uniq); do

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
