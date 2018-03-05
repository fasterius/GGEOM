#!/usr/bin/env Rscript

# Install missing packages (if applicable)
packages <- c("argparse", "GEOquery")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    message("Installing missing packages ...")
    tryCatch(silent = TRUE,
        install.packages(setdiff(packages, rownames(installed.packages())),
                         repos = "http://cran.us.r-project.org"),
        warning = function(bc) {
            source("http://bioconductor.org/biocLite.R")
            biocLite(setdiff(packages, rownames(installed.packages())))
        },
        error = function(bc) {
            source("http://bioconductor.org/biocLite.R")
            biocLite(setdiff(packages, rownames(installed.packages())))
        })
}

# Command parser
suppressPackageStartupMessages(library("argparse"))
parser <- ArgumentParser(epilog = "Collect GEO/SRA metadata for series.")
parser$add_argument("input",
                    type    = "character",
                    help    = "input file path or GSE ID")
parser$add_argument("output",
                    type    = "character",
                    help    = "output file path")
parser$add_argument("-a", "--all-types",
                    action  = "store_true",
                    dest    = "all_types",
                    help    = "get metadata of all types, not just RNA-seq")
args <- parser$parse_args()

# Data ------------------------------------------------------------------------

# Check and process input file type
if (grepl(".txt", args$input)) {
    gse.list <- read.table(args$input, sep = "\t", header = FALSE, 
                    stringsAsFactors = FALSE)
    names(gse.list) <- "GSE"
} else {
    gse.list <- data.frame(GSE = args$input)
}

# Remove previous output file (if applicable)
if (file.exists(args$output)) {
    file.remove(args$output)
}

# Analysis --------------------------------------------------------------------

# Load packages
suppressPackageStartupMessages(library("GEOquery"))

# For every series in list
for (series in gse.list[["GSE"]]) {

    # Download current series
    gse <- tryCatch({
        gse <- getGEO(series, GSEMatrix = FALSE)
    }, error = function(cond) {
        return(NULL)
    })

    # Go to next series if error during download of series
    if (is.null(gse)) {
        message("Error during download of ", series, "; skipping.")
        write(paste(series, collapse = "\t"),
              sep    = "\t",
              append = TRUE,
              "errors.gse.txt")
        next
    }

    # Get corresponding SRP ID
    srp <- grep("SRP", Meta(gse)$relation, value = TRUE)
    srp <- strsplit(srp, "term=")[[1]][2]

    # For every sample in the series
    for (sample in Meta(gse)$sample_id) {

        # Current sample
        gsm <- tryCatch({
            gsm <- getGEO(sample)
        }, error = function(cond) {
            return(NULL)
        })

        # Go to next sample if error during download of sample
        if (is.null(gsm)) {
            message("Error during download of ", sample, "; skipping.")
            write(paste(sample, collapse = "\t"),
                  sep    = "\t",
                  append = TRUE,
                  "errors.gsm.txt")
            next
        }

        # Get metadata
        info <- Meta(gsm)

        # Check for RNA, cell lines, SRA, species and permitted platforms
        if (any(grepl("RNA", info$molecule_ch1, ignore.case = TRUE)) &
            any(grepl("SRA", info$relation)) &
            info$organism_ch1 == "Homo sapiens" | args$all_types) {

        # Collapse multi-entry metadata into single entries
        for (m in 1:length(names(info))) {
            info[m] <- paste(unlist(info[m]), collapse = "; ")
        }

        # Metadata entries to collect
        entries <- c("series_id",
                     "geo_accession",
                     "title",
                     "source_name_ch1",
                     "characteristics_ch1",
                     "growth_protocol_ch1",
                     "treatment_protocol_ch1",
                     "extract_protocol_ch1",
                     "molecule_ch1",
                     "library_source",
                     "library_selection",
                     "library_strategy",
                     "submission_date",
                     "status",
                     "last_update_date",
                     "organism_ch1",
                     "taxid_ch1", 
                     "platform_id",
                     "instrument_model",
                     "description",
                     "data_processing",
                     "data_row_count",
                     "relation",
                     "type",
                     "channel_count",
                     "contact_address",
                     "contact_city",
                     "contact_country",
                     "contact_email",
                     "contact_institute",
                     "contact_name",
                     "contact_state",
                     "contact_zip/postal_code")

        # Build metadata data frame
        metadata <- data.frame(row.names = 1)
        for (entry in entries) {
            if (entry %in% names(info)) {
                metadata[entry] <- info[entry]
            } else {
                metadata[entry] <- ""
            }
        }

        # Rename columns
        names(metadata) <- c("GSE", "GSM", names(metadata)[3:33])
        names(metadata) <- gsub("_ch1", "", names(metadata))

        # Add SRX and SRP columns
        metadata["SRP"] <- srp

        # Reorder columns
        metadata <- metadata[c("GSE", "GSM", "SRP", names(metadata)[3:33])]

        # Check if metadata file already exists, otherwise create it
        if (!file.exists(args$output)) {
            write(paste(names(metadata), collapse = "\t"), args$output)
        }

        # Append to metadata file
        write.table(metadata,
                    args$output,
                    sep       = "\t",
                    row.names = FALSE,
                    col.names = FALSE,
                    quote     = FALSE,
                    append    = TRUE)
        closeAllConnections()

        }
    }
}
