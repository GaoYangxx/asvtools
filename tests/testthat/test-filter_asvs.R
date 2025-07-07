# test-filter_asvs.R

# No need to load asvtools, dplyr, reshape2 here, as helper.R (or testthat itself) handles it.

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
  expect_error(
    filter_asvs(asv_counts_df = data.frame()),
    "must be a non-empty data frame"
  )
  expect_error(
    filter_asvs(asv_counts_df = matrix(1:4, 2, 2)),
    "must be a non-empty data frame"
  )
  expect_error(
    filter_asvs(asv_counts_df = asv_counts_mock, metadata_df = data.frame())
  )
  expect_error(
    filter_asvs(asv_counts_df = asv_counts_mock, metadata_df = metadata_mock, group_column_name = "NonExistent")
  )
})

test_that("filter_asvs handles warning for unmatched metadata samples", {
  # Create metadata with a sample not in asv_counts_mock (columns)
  metadata_unmatched <- data.frame(
    Group = c("A", "A", "B", "B", "C"),
    stringsAsFactors = FALSE,
    row.names = c("JRG_1", "JRG_2", "JRG_3", "JRG_4", "SAMPLE_EXTRA")
  )
  expect_warning(
    filter_asvs(asv_counts_mock, metadata_df = metadata_unmatched, group_column_name = "Group"),
    "could not be matched"
  )
})

test_that("filter_asvs correctly handles message when group filtering is skipped", {
  # Capture messages
  expect_message(
    filter_asvs(asv_counts_df = asv_counts_mock, metadata_df = NULL),
    "No `metadata_df` or `group_column_name` provided; skipping group-based filtering."
  )
})
