# tests/testthat/helper.R

# Load common dependencies needed across multiple tests or for data manipulation
# These are typically in 'Imports' in your DESCRIPTION file
library(dplyr)
library(reshape2)
library(testthat) # testthat itself is often loaded here for helpers

# --- Mock ASV Count Data (ASVs_mock_data) ---
# This data frame mocks ASV count data for testing purposes.
# It represents read counts for various ASVs (rows) across different samples (columns).
# Row names are ASV IDs, and column names are Sample IDs.
ASVs_mock_data <- data.frame(
  JRG_1 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 18, 0, 0, 0, 33, 33, 0, 37, 0, 0, 0, 0, 0, 38, 0),
  JRG_2 = c(0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 23, 0, 0, 0, 0, 29, 0, 0, 0, 32, 0, 0, 44, 0, 0, 0, 0, 0, 22, 0),
  JRG_3 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 36, 12, 0, 5, 0, 46, 0, 0, 0, 0, 0, 0, 25, 0, 0, 0, 0, 0, 28, 0),
  JRG_4 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 19, 0, 0, 0, 27, 0, 83, 0, 27, 25, 0, 0, 0, 34, 37, 0, 29, 0, 0, 0, 0, 0, 19, 0),
  JRG_5 = c(0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 0, 0, 0, 0, 43, 0, 20, 0, 0, 0, 0, 0, 18, 0),
  JRG_6 = c(0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 0, 22, 0),
  JJG_1 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 38, 49, 0, 0, 25, 28, 0, 0, 48, 0, 9, 18, 105, 0, 0, 0, 0, 44, 62, 9),
  JJG_2 = c(0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 64, 0, 0, 26, 31, 0, 0, 31, 23, 8, 0, 155, 0, 0, 15, 0, 52, 79, 16),
  JJG_3 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 45, 0, 41, 30, 0, 0, 0, 26, 0, 11, 0, 213, 0, 0, 0, 0, 59, 51, 24),
  JJG_4 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 3, 31, 56, 0, 15, 24, 37, 15, 0, 33, 10, 13, 0, 65, 41, 0, 14, 0, 37, 81, 19),
  JJG_5 = c(0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 32, 0, 0, 66, 55, 0, 0, 36, 0, 12, 0, 111, 0, 0, 0, 0, 62, 44, 30),
  JJG_6 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 0, 0, 33, 21, 0, 0, 25, 0, 7, 34, 102, 0, 0, 0, 5, 57, 37, 30),
  TZG_1 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 36, 15, 0, 50, 0, 20, 0, 23, 16, 20, 4, 0, 0, 35, 25, 30, 224, 0, 0, 14),
  TZG_2 = c(0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35, 14, 0, 0, 0, 0, 18, 18, 0, 0, 0, 49, 0, 61, 52, 24, 88, 34, 0, 10),
  TZG_3 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 39, 12, 121, 0, 0, 25, 26, 15, 26, 0, 0, 0, 76, 87, 37, 0, 61, 0, 0, 0),
  TZG_4 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 14, 0, 31, 0, 25, 14, 18, 0, 0, 0, 0, 0, 43, 25, 0, 66, 0, 0, 24),
  TZG_5 = c(2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 53, 0, 103, 0, 0, 0, 0, 10, 0, 0, 3, 0, 0, 63, 32, 24, 142, 32, 0, 0),
  TZG_6 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 12, 0, 32, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 29, 0, 60, 0, 0, 14),
  PAG_1 = c(0, 0, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 8, 0, 34, 0, 0, 0, 16, 122, 0, 0, 0, 0, 0, 23, 25, 0, 0, 34, 0),
  PAG_2 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 9, 0, 0, 0, 0, 10, 0, 122, 0, 0, 0, 0, 0, 27, 21, 0, 0, 0, 0),
  PAG_3 = c(0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 5, 4, 79, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0),
  PAG_4 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 8, 7, 428, 0, 0, 0, 0, 0, 0, 38, 0, 0, 15, 0),
  PAG_5 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 11, 18, 598, 0, 0, 0, 0, 0, 0, 34, 0, 0, 0, 0),
  PAG_6 = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 36, 0, 0, 9, 0, 161, 0, 0, 0, 0, 0, 29, 23, 0, 0, 42, 0),
  row.names = c("ASV33223", "ASV25409", "ASV28883", "ASV70267", "ASV48196", "ASV40031", "ASV65646", "ASV8421", "ASV58120", "ASV52240", "ASV16749", "ASV14431", "ASV75284", "ASV29542", "ASV59240", "ASV71098", "ASV11980", "ASV34954", "ASV43989", "ASV16613", "ASV201", "ASV138", "ASV11736", "ASV207", "ASV323", "ASV4139", "ASV4011", "ASV6667", "ASV317", "ASV11791", "ASV712", "ASV6543", "ASV14", "ASV6519", "ASV3823", "ASV3800", "ASV5338", "ASV105", "ASV117", "ASV337")
)
# Ensure it's a data frame, and handle row/column names as expected by functions
asv_counts_mock <- as.data.frame(ASVs_mock_data)


# --- Mock Metadata (metadata_mock) ---
# This data frame mocks sample metadata for testing purposes.
# Row names should correspond to Sample IDs in ASVs_mock_data's columns.
metadata_mock_data <- data.frame(
  Sample.ID = c("JRG_1", "JRG_2", "JRG_3", "JRG_4", "JRG_5", "JRG_6", "JJG_1", "JJG_2", "JJG_3", "JJG_4", "JJG_5", "JJG_6", "TZG_1", "TZG_2", "TZG_3", "TZG_4", "TZG_5", "TZG_6", "PAG_1", "PAG_2", "PAG_3", "PAG_4", "PAG_5", "PAG_6"),
  Group = c("JRG", "JRG", "JRG", "JRG", "JRG", "JRG", "JJG", "JJG", "JJG", "JJG", "JJG", "JJG", "TZG", "TZG", "TZG", "TZG", "TZG", "TZG", "PAG", "PAG", "PAG", "PAG", "PAG", "PAG"),
  Origin = c("JR", "JR", "JR", "JR", "JR", "JR", "JJ", "JJ", "JJ", "JJ", "JJ", "JJ", "TZ", "TZ", "TZ", "TZ", "TZ", "TZ", "PA", "PA", "PA", "PA", "PA", "PA"),
  Niche = c("G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G"),
  row.names = c("JRG_1", "JRG_2", "JRG_3", "JRG_4", "JRG_5", "JRG_6", "JJG_1", "JJG_2", "JJG_3", "JJG_4", "JJG_5", "JJG_6", "TZG_1", "TZG_2", "TZG_3", "TZG_4", "TZG_5", "TZG_6", "PAG_1", "PAG_2", "PAG_3", "PAG_4", "PAG_5", "PAG_6"),
  stringsAsFactors = FALSE
)
metadata_mock <- as.data.frame(metadata_mock_data)

# --- Common Helper Functions (Optional) ---
# If you find yourself repeatedly calculating intermediate values for your
# 'expected' results in multiple test files, you can define helper functions here.
# For example, a function to calculate relative abundance:
# calculate_relative_abundance <- function(asv_counts_df) {
#   as.data.frame(t(t(asv_counts_df) / colSums(asv_counts_df)))
# }

# Or a function to calculate group presence counts:
# calculate_group_presence_counts <- function(asv_counts_df, metadata_df, group_col_name) {
#   b_abs_long <- reshape2::melt(as.matrix(asv_counts_df), varnames = c("ASV", "Sample"))
#   sample_Groups <- metadata_df[[group_col_name]]
#   names(sample_Groups) <- rownames(metadata_df)
#   b_abs_long$Group <- sample_Groups[match(b_abs_long$Sample, names(sample_Groups))]
#
#   asv_group_presence_count <- b_abs_long %>%
#     dplyr::filter(value > 0, !is.na(Group)) %>%
#     dplyr::group_by(ASV) %>%
#     dplyr::summarise(unique_groups_present = dplyr::n_distinct(Group), .groups = "drop")
#
#   return(asv_group_presence_count)
# }
