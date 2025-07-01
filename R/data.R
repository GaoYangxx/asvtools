# R/data.R

#' ASV Counts Table
#'
#' A comprehensive dataset containing Amplicon Sequence Variant (ASV) read counts
#' across various samples. This data is typically generated from 16S rRNA gene sequencing
#' and has been pre-processed to include only filtered and deduplicated ASVs.
#'
#' @format A data frame with 40 rows (representing unique ASVs) and
#'   24 columns (representing individual samples). The values within
#'   the data frame are integer read counts. The row names are ASV identifiers.
#' \describe{
#'   \item{JRG_1, JRG_2, JRG_3, JRG_4, JRG_5, JRG_6}{Integer read counts for individual samples from the JRG group.}
#'   \item{JJG_1, JJG_2, JJG_3, JJG_4, JJG_5, JJG_6}{Integer read counts for individual samples from the JJG group.}
#'   \item{TZG_1, TZG_2, TZG_3, TZG_4, TZG_5, TZG_6}{Integer read counts for individual samples from the TZG group.}
#'   \item{PAG_1, PAG_2, PAG_3, PAG_4, PAG_5, PAG_6}{Integer read counts for individual samples from the PAG group.}
#' }
#' @details
#' The `ASVs` dataset is a core component for downstream microbial community
#' analyses, including diversity calculations, differential abundance testing,
#' and compositional analyses. It includes samples from JRG, JJG, TZG, and PAG groups.
#' @source This dataset was derived from raw sequencing data, undergoing initial
#'   quality filtering, denoising, and chimera removal steps using DADA2,
#'   followed by sample- and group-based filtering criteria.
#' @examples
#' \dontrun{
#' # To view the first few rows of the ASV table:
#' head(ASVs)
#'
#' # To check the dimensions:
#' dim(ASVs)
#'
#' # Access counts for a specific sample, e.g., JRG_1
#' ASVs$JRG_1
#' }
"ASVs"

#' Sample Metadata
#'
#' A dataset providing essential metadata for each sample included in the
#' ASV count table. This information is crucial for grouping samples and
#' performing biologically relevant comparisons.
#'
#' @format A data frame with 24 rows (each representing a unique sample) and
#'   4 columns (representing different metadata variables).
#' \describe{
#'   \item{Sample.ID}{Character string. Unique identifier for each sample, also serving as the row names (e.g., "JRG_1", "JJG_2").}
#'   \item{Group}{Factor. Indicates the primary experimental group or treatment for each sample (Levels: JRG, JJG, TZG, PAG).}
#'   \item{Origin}{Character string or factor. Represents the geographical or biological origin of the sample (Levels: JR, JJ, TZ, PA).}
#'   \item{Niche}{Character string or factor. Indicates the specific ecological niche or environment from which the sample was collected (Level: G).}
#' }
#' @details
#' This metadata table is designed to be directly joined or used in conjunction
#' with the `ASVs` dataset, using `Sample.ID` as the linking key, for various
#' statistical and visualization purposes.
#' @source Collected during the experimental design phase of the study.
#' @examples
#' \dontrun{
#' # To view the first few rows of the metadata:
#' head(metadata)
#'
#' # To check the structure:
#' str(metadata)
#'
#' # Get the 'Group' for all samples
#' metadata$Group
#' }
"metadata"
