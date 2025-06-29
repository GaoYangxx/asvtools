# Load your package and dependencies for testing
library(testthat)
library(asvtools) # Load your package
library(dplyr)
library(reshape2)

# --- Create ASVs ---
# This data frame mocks your ASV count data for testing purposes.
ASVs <- data.frame(
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

# --- Create metadata ---
# This data frame mocks your metadata for testing purposes.
metadata <- data.frame(
  Sample.ID = c("JRG_1", "JRG_2", "JRG_3", "JRG_4", "JRG_5", "JRG_6", "JJG_1", "JJG_2", "JJG_3", "JJG_4", "JJG_5", "JJG_6", "TZG_1", "TZG_2", "TZG_3", "TZG_4", "TZG_5", "TZG_6", "PAG_1", "PAG_2", "PAG_3", "PAG_4", "PAG_5", "PAG_6"),
  Group = c("JRG", "JRG", "JRG", "JRG", "JRG", "JRG", "JJG", "JJG", "JJG", "JJG", "JJG", "JJG", "TZG", "TZG", "TZG", "TZG", "TZG", "TZG", "PAG", "PAG", "PAG", "PAG", "PAG", "PAG"),
  Origin = c("JR", "JR", "JR", "JR", "JR", "JR", "JJ", "JJ", "JJ", "JJ", "JJ", "JJ", "TZ", "TZ", "TZ", "TZ", "TZ", "TZ", "PA", "PA", "PA", "PA", "PA", "PA"),
  Niche = c("G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G"),
  row.names = c("JRG_1", "JRG_2", "JRG_3", "JRG_4", "JRG_5", "JRG_6", "JJG_1", "JJG_2", "JJG_3", "JJG_4", "JJG_5", "JJG_6", "TZG_1", "TZG_2", "TZG_3", "TZG_4", "TZG_5", "TZG_6", "PAG_1", "PAG_2", "PAG_3", "PAG_4", "PAG_5", "PAG_6"),
  stringsAsFactors = FALSE # Important for character columns
)

# --- Test Setup ---
# Use the provided 'ASVs' as mock ASV count data
# Ensure it's a data frame with proper row and column names for the function
asv_counts_mock <- as.data.frame(ASVs)

# Use the provided 'metadata' as mock metadata
metadata_mock <- as.data.frame(metadata)
# Ensure metadata row names match sample IDs in asv_counts_mock (columns)
# It seems your provided metadata already has sample IDs as row names, which is great.

# --- Test Cases ---

test_that("filter_asvs returns correct dimensions with no filtering (defaults)", {
  # When all min_* parameters are 0, it should return the original dataframe
  result <- filter_asvs(asv_counts_df = asv_counts_mock)
  expect_equal(dim(result), dim(asv_counts_mock))
  expect_equal(rownames(result), rownames(asv_counts_mock))
})

test_that("filter_asvs handles min_samples_present correctly", {
  # Test with min_samples_present = 1.
  # All 40 ASVs in your provided data should have a sum greater than 0.
  expected_asvs_present_at_least_1 <- rownames(asv_counts_mock)

  result_min_1_sample <- filter_asvs(asv_counts_df = asv_counts_mock, min_samples_present = 1)
  expect_equal(sort(rownames(result_min_1_sample)), sort(expected_asvs_present_at_least_1))
  expect_equal(nrow(result_min_1_sample), 40) # There are 40 ASVs in the mock data

  # Test with min_samples_present = 3.
  # Find ASVs present in at least 3 samples (count > 0).
  expected_asvs_min_3_samples_present <- rownames(asv_counts_mock)[rowSums(asv_counts_mock > 0) >= 3]

  result_min_3_samples <- filter_asvs(asv_counts_df = asv_counts_mock, min_samples_present = 3)
  expect_equal(sort(rownames(result_min_3_samples)), sort(expected_asvs_min_3_samples_present))
  expect_equal(nrow(result_min_3_samples), length(expected_asvs_min_3_samples_present))
})

test_that("filter_asvs handles min_abs_abundance_value correctly", {
  # Test with min_abs_abundance_value = 5 and min_samples_present = 2.
  # This condition means: sum(count >= 5) >= 2.
  mask_abs_abundance <- apply(asv_counts_mock, 1, function(row) {
    sum(row >= 5) >= 2
  })
  expected_asvs_abs_abundance <- rownames(asv_counts_mock)[mask_abs_abundance]

  result <- filter_asvs(
    asv_counts_df = asv_counts_mock,
    min_samples_present = 2, # This threshold applies to both sum(>0) and sum(>=min_abs_abundance_value)
    min_abs_abundance_value = 5
  )
  expect_equal(sort(rownames(result)), sort(expected_asvs_abs_abundance))
  expect_equal(nrow(result), length(expected_asvs_abs_abundance))
})


test_that("filter_asvs handles min_overall_avg_rel_abundance correctly", {
  # Calculate overall average relative abundance for mock data.
  relative_abundance <- as.data.frame(
    t(t(asv_counts_mock) / colSums(asv_counts_mock))
  )
  asv_overall_avg_rel_abundance <- rowMeans(relative_abundance)

  # Set a threshold, for example, 0.005 (0.5%).
  expected_asvs_high_rel_abundance <- rownames(asv_counts_mock)[asv_overall_avg_rel_abundance >= 0.005]

  result <- filter_asvs(asv_counts_df = asv_counts_mock, min_overall_avg_rel_abundance = 0.005)
  expect_equal(sort(rownames(result)), sort(expected_asvs_high_rel_abundance))
  expect_equal(nrow(result), length(expected_asvs_high_rel_abundance))
})

test_that("filter_asvs handles group_column_name correctly (min_groups_present)", {
  # The 'Group' column in your metadata_mock has 4 unique groups: JRG, JJG, TZG, PAG.

  # Test with min_groups_present = 1 (Any ASV with count > 0 should pass this).
  expected_asvs_in_1_group <- rownames(asv_counts_mock)[rowSums(asv_counts_mock) > 0]

  result_min_1_group <- filter_asvs(
    asv_counts_df = asv_counts_mock,
    metadata_df = metadata_mock,
    group_column_name = "Group",
    min_groups_present = 1
  )
  expect_equal(sort(rownames(result_min_1_group)), sort(expected_asvs_in_1_group))
  expect_equal(nrow(result_min_1_group), length(expected_asvs_in_1_group)) # Expect all 40 ASVs

  # Test with min_groups_present = 3.
  # This section recalculates group presence for robustness within the test.
  b_abs_long_test <- reshape2::melt(as.matrix(asv_counts_mock), varnames = c("ASV", "Sample"))
  sample_Groups_test <- metadata_mock[["Group"]]
  names(sample_Groups_test) <- rownames(metadata_mock)
  b_abs_long_test$Group <- sample_Groups_test[match(b_abs_long_test$Sample, names(sample_Groups_test))]

  asv_group_presence_count_test <- b_abs_long_test %>%
    dplyr::filter(value > 0, !is.na(Group)) %>%
    dplyr::group_by(ASV) %>%
    dplyr::summarise(unique_groups_present = dplyr::n_distinct(Group), .groups = "drop")

  expected_asvs_in_3_groups <- as.character(asv_group_presence_count_test$ASV[
    asv_group_presence_count_test$unique_groups_present >= 3
  ])

  result_min_3_groups <- filter_asvs(
    asv_counts_df = asv_counts_mock,
    metadata_df = metadata_mock,
    group_column_name = "Group",
    min_groups_present = 3
  )
  expect_equal(sort(rownames(result_min_3_groups)), sort(expected_asvs_in_3_groups))
  expect_equal(nrow(result_min_3_groups), length(expected_asvs_in_3_groups))
})

test_that("filter_asvs combines multiple criteria correctly", {
  # This is the most important test, combining all active filters.
  # We set non-trivial thresholds that should filter a good number of ASVs.

  # Criteria:
  # 1. min_samples_present = 3
  # 2. min_abs_abundance_value = 5 (meaning count >= 5 in at least 3 samples, based on function's internal logic)
  # 3. min_groups_present = 3
  # 4. min_overall_avg_rel_abundance = 0.005

  # Determine expected ASVs by applying all masks based on the internal logic.

  # Condition 1 & 2 combined: min_samples_present = 3 (for both >0 and >= value)
  mask_s_p_and_abs_val <- apply(asv_counts_mock, 1, function(row) {
    sum(row > 0) >= 3 && sum(row >= 5) >= 3 # Using 3 for both as per function's logic
  })

  # Condition 3: min_groups_present = 3
  # Recalculate group presence data for this test block.
  b_abs_long_test <- reshape2::melt(as.matrix(asv_counts_mock), varnames = c("ASV", "Sample"))
  sample_Groups_test <- metadata_mock[["Group"]]
  names(sample_Groups_test) <- rownames(metadata_mock)
  b_abs_long_test$Group <- sample_Groups_test[match(b_abs_long_test$Sample, names(sample_Groups_test))]
  asv_group_presence_count_test <- b_abs_long_test %>%
    dplyr::filter(value > 0, !is.na(Group)) %>%
    dplyr::group_by(ASV) %>%
    dplyr::summarise(unique_groups_present = dplyr::n_distinct(Group), .groups = "drop")

  mask_groups <- as.character(asv_group_presence_count_test$ASV[
    asv_group_presence_count_test$unique_groups_present >= 3
  ])

  # Condition 4: min_overall_avg_rel_abundance = 0.005
  # Recalculate relative abundance data for this test block.
  relative_abundance <- as.data.frame(
    t(t(asv_counts_mock) / colSums(asv_counts_mock))
  )
  asv_overall_avg_rel_abundance <- rowMeans(relative_abundance)
  mask_avg_rel_abund <- rownames(asv_counts_mock)[asv_overall_avg_rel_abundance >= 0.005]

  # Combine all masks:
  expected_combined_asvs <- rownames(asv_counts_mock)[mask_s_p_and_abs_val]
  expected_combined_asvs <- intersect(expected_combined_asvs, mask_groups)
  expected_combined_asvs <- intersect(expected_combined_asvs, mask_avg_rel_abund)

  result <- filter_asvs(
    asv_counts_df = asv_counts_mock,
    metadata_df = metadata_mock,
    group_column_name = "Group",
    min_samples_present = 3,
    min_abs_abundance_value = 5,
    min_groups_present = 3,
    min_overall_avg_rel_abundance = 0.005
  )
  expect_equal(sort(rownames(result)), sort(expected_combined_asvs))
  expect_equal(nrow(result), length(expected_combined_asvs))
})

test_that("filter_asvs handles edge cases for input data (empty/invalid)", {
  expect_error(filter_asvs(asv_counts_df = data.frame()),
               "`asv_counts_df` must be a data frame with non-NULL row and column names.")
  expect_error(filter_asvs(asv_counts_df = matrix(1:4, 2, 2)),
               "`asv_counts_df` must be a data frame with non-NULL row and column names.")
  expect_error(
    filter_asvs(asv_counts_df = asv_counts_mock, metadata_df = data.frame()),
    regexp = "must be a data frame with non-NULL row names"
  )
  expect_error(filter_asvs(asv_counts_df = asv_counts_mock, metadata_df = metadata_mock, group_column_name = "NonExistent"),
               "Error: The specified group column 'NonExistent' was not found in the metadata. Please check the column name.")
})

test_that("filter_asvs handles warning for unmatched metadata samples", {
  # Create metadata with a sample not in asv_counts_mock (columns)
  metadata_unmatched <- data.frame(
    Group = c("A", "A", "B", "B", "C"),
    stringsAsFactors = FALSE,
    row.names = c("JRG_1", "JRG_2", "JRG_3", "JRG_4", "SAMPLE_EXTRA")
  )
  expect_warning(filter_asvs(asv_counts_mock, metadata_df = metadata_unmatched, group_column_name = "Group"),
                 "Warning: Some samples in the metadata could not be matched to their corresponding group information.")
})

test_that("filter_asvs correctly handles message when group filtering is skipped", {
  # Capture messages
  expect_message(
    filter_asvs(asv_counts_df = asv_counts_mock, metadata_df = NULL),
    "No `metadata_df` or `group_column_name` provided; skipping group-based filtering."
  )
})
