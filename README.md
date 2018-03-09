# GGEOM
[![License: MIT][badge]][licence]

## Overview

**GGEOM** is a small collection of scripts to **G**et and parse **G**ene
**E**xpression **O**mnibus [(GEO)][geo] **M**etadata, for use in downstream
pipelines for download and analysis of the raw data the metadata describes
(such as my own [RNA-VC][rna-vc]). It collects both the metadata stored in the
GEO (which contains things such as experimental designs, treatment protocols,
sample names, *etc.*) and the associated SRA ([Sequence Read Archive][sra])
study (containing things such as sequencing depth, read layouts, instrument,
and so on).

GGEOM collects the often non-overlapping metadata from the two databases,
showing the full scope of each dataset. The metadata can then manually curated
to only include the specific samples of interest, or used as-is. Some level of
curation is, however, recommended.

I created GGEOM in order to more easily fetch the metadata I need for my own
research, but I share it here on GitHub in case that somebody else has a use
for it as well. There are no guarantees that it'll work for you, though, but
I'll happily provide help if you're having issues with using it!

## Usage

GGEOM is a mix of R scripts, command line tools and a wrapper in bash. It 
requires a small number of software packages to function:

 * [GEOquery][geoquery] and [argparse][argparse] for querying the GEO through R
 * [Entrez E-Utilities][e-utils] for downloading SRA metadata

To download the GGEOM scripts, simply `clone` this repository:

```bash
git clone https://github.com/fasterius/GGEOM
```

All four scripts need to be placed on your `PATH`. GGEOM can be run on either a
single GSE ID or on a list of IDs:

```bash
# Run on a single GSE ID
ggeom.sh GSE81194

# Run on a list of GSE IDs in a .txt file
ggeom.sh series.txt
```

After a successful run the file `metadata.txt` will be placed in the current
directory, containing all the metadata that GGEOM found.

## License

GGEOM is available with a MIT licence. It is free software: you may
redistribute it and/or modify it under the terms of the MIT licence. For more
information, please see the `LICENCE` file.

[badge]: https://img.shields.io/badge/license-mit-blue.svg
[licence]: https://opensource.org/licenses/mit

[argparse]: https://cran.r-project.org/web/packages/argparse/index.html
[e-utils]: https://www.ncbi.nlm.nih.gov/books/NBK179288/
[geo]: https://www.ncbi.nlm.nih.gov/geo/
[geoquery]: https://bioconductor.org/packages/release/bioc/html/GEOquery.html
[rna-vc]: https://github.com/fasterius/RNA-VC
[sra]: https://www.ncbi.nlm.nih.gov/sra
