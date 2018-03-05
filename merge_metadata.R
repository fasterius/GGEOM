#!/usr/bin/env Rscript

# Read GEO metadata
geo_metadata <- read.table("geo_metadata.txt",
                           sep              = "\t",
                           fill             = TRUE,
                           quote            = NULL,
                           header           = TRUE,
                           stringsAsFactors = FALSE)

# Read SRA metadata
sra_metadata <- read.table("sra_metadata.txt",
                           sep              = "\t",
                           fill             = TRUE,
                           quote            = NULL,
                           header           = TRUE,
                           stringsAsFactors = FALSE)

# Merge GEO and SRA metadata
metadata <- merge(geo_metadata,
                  sra_metadata,
                  by.x = "GSM",
                  by.y = "SampleName")

# Reorder columns
first_cols <- c("GSE",
                "GSM",
                "SRP",
                "SRR",
                "title",
                "source_name",
                "characteristics",
                "growth_protocol",
                "treatment_protocol",
                "extract_protocol",
                "molecule",
                "library_source",
                "library_selection",
                "library_strategy",
                "LibraryLayout",
                "spots",
                "spots_with_mates",
                "avgLength",
                "size_MB")
other_cols <- names(metadata)[!(names(metadata) %in% first_cols)]
metadata <- metadata[c(first_cols, other_cols)]

# Write merged metadata to file
write.table(metadata,
            "metadata.txt",
            sep       = "\t",
            quote     = FALSE,
            row.names = FALSE)
