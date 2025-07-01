library(dplyr)
library(asvtools)

raw_asv_counts_path <- file.path("data-raw", "ASVs.rds")
raw_metadata_path <- file.path("data-raw", "metadata.rds")

ASVs <- readRDS(raw_asv_counts_path)
metadata <- readRDS(raw_metadata_path)

b_ASV_sampled_initial <- data.frame(ASVs) %>%
  sample_n(20)

message("Initial sampling results dimension:")
print(dim(b_ASV_sampled_initial))

min_samples_present_val <- 3
min_abs_abundance_val <- 3
min_groups_present_val <- 2
min_overall_avg_rel_abundance_val <- 0.0001

group_col_name <- "Group"

filtered_asv_counts_with_group <- filter_asvs(
  asv_counts_df = b_ASV1_filtered,
  metadata_df = metadata_df_for_filter,
  group_column_name = group_col_name,
  min_samples_present = min_samples_present_val,
  min_abs_abundance_value = min_abs_abundance_val,
  min_groups_present = min_groups_present_val,
  min_overall_avg_rel_abundance = min_overall_avg_rel_abundance_val
)

message("Final filtered ASV counts table dimension (with group filter):")
print(dim(filtered_asv_counts_with_group))

message("Final filtered ASV counts table head (with group filter):")
print(head(filtered_asv_counts_with_group))

b_ASV_sampled_filtered <- data.frame(filtered_asv_counts_with_group) %>%
  sample_n(20)

message("Filtered sampling results dimension:")
print(dim(b_ASV_sampled_filtered))

combined_asv_samples <- bind_rows(b_ASV_sampled_initial, b_ASV_sampled_filtered)

message("Combined data frame dimension:")
print(dim(combined_asv_samples))

deduplicated_asv_samples <- combined_asv_samples %>%
  distinct()

message("Deduplicated data frame dimension:")
print(dim(deduplicated_asv_samples))

message("Deduplicated and combined ASV sample data:")
print(deduplicated_asv_samples)

metadata_processed <- data.frame(metadata)

metadata_processed <- metadata_processed[, 1:4]

metadata_processed <- metadata_processed[1:24, ]

message("Processed metadata table:")
print(metadata_processed)

usethis::use_data(ASVs, overwrite = TRUE)
usethis::use_data(metadata, overwrite = TRUE)
