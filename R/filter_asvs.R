# Ensure you have 'dplyr', 'reshape2' packages installed and loaded
# install.packages(c("dplyr", "reshape2")) # Uncomment and run if not installed
library(dplyr)
library(reshape2)

# --- Define Global Variables to Suppress 'no visible binding for global variable' Notes ---
# This line is crucial for R CMD check, telling it that these variables
# (commonly column names in dplyr operations) are expected to be global.
utils::globalVariables(c("ASV", "Group", "value"))

# --- Roxygen2 Imports for Functions Used Without '::' Prefix ---
#' @importFrom dplyr select filter group_by summarise n_distinct
#' @importFrom magrittr %>%
#' @importFrom reshape2 melt
#'
#' @title Filter ASVs Based on Multiple Criteria
#'
#' @description This function filters ASVs based on four conditions:
#' \enumerate{
#' \item Presence in at least `min_samples_present` samples (absolute abundance > 0).
#' \item Absolute abundance greater than `min_abs_abundance_value` in at least
#'       `min_samples_present` samples.
#' \item (Optional) Presence in at least `min_groups_present` groups
#'       (absolute abundance > 0) defined by the `group_column_name`.
#' \item Overall average relative abundance of the ASV across all samples
#'       is greater than `min_overall_avg_rel_abundance`.
#' }
#'
#' @param asv_counts_df A data frame of ASV counts, with ASV IDs as row names and sample IDs as column names.
#' @param metadata_df (Optional) A data frame of sample metadata, with sample IDs as row names.
#'                    If provided, grouping filter will be applied based on `group_column_name`.
#'                    Default is NULL.
#' @param group_column_name (Optional) Character string, the name of the column in `metadata_df`
#'                          to use for grouping. Only effective if `metadata_df` is provided.
#'                          Default is NULL.
#' @param min_samples_present Minimum number of samples an ASV must be present in (absolute abundance > 0).
#' @param min_abs_abundance_value Threshold for absolute abundance; an ASV's count in a sample must be
#'                                 greater than or equal to this value to be considered "present" for
#'                                 this specific condition.
#' @param min_groups_present Minimum number of groups an ASV must be present in (absolute abundance > 0).
#'                           Only applicable when `metadata_df` and `group_column_name` are provided.
#' @param min_overall_avg_rel_abundance Threshold for the ASV's overall average relative abundance across all samples.
#'
#' @return A data frame of filtered ASV counts, containing only ASVs that meet all specified criteria.
#' @export
#'
#' @examples
#' # Assuming b_ASV and metadata_df are already prepared (as shown in previous examples)
#'
#' # Example 1: Use all filtering criteria (including grouping)
#' # filtered_asvs_full <- filter_asvs(
#' #   asv_counts_df = b_ASV,
#' #   metadata_df = metadata_df,
#' #   group_column_name = "Group", # Assuming 'Group' column exists in metadata
#' #   min_samples_present = 3,
#' #   min_abs_abundance_value = 3,
#' #   min_groups_present = 2,
#' #   min_overall_avg_rel_abundance = 0.0001
#' # )
#' # print(filtered_asvs_full)
#'
#' # Example 2: Without grouping filter (metadata_df and group_column_name are NULL)
#' # filtered_asvs_no_group <- filter_asvs(
#' #   asv_counts_df = b_ASV,
#' #   min_samples_present = 3,
#' #   min_abs_abundance_value = 3,
#' #   min_overall_avg_rel_abundance = 0.0001 # min_groups_present will be ignored
#' # )
#' # print(filtered_asvs_no_group)
filter_asvs <- function(asv_counts_df, metadata_df = NULL, group_column_name = NULL,
                        min_samples_present = 0,
                        min_abs_abundance_value = 0,
                        min_groups_present = 0,
                        min_overall_avg_rel_abundance = 0) {

  # Check input data
  if (!is.data.frame(asv_counts_df) || is.null(rownames(asv_counts_df)) || is.null(colnames(asv_counts_df))) {
    stop("`asv_counts_df` must be a data frame with non-NULL row and column names.")
  }

  # --- Step 1: Calculate relative abundance and identify ASVs present in enough groups ---

  # 1.1 Calculate relative abundance within each sample
  relative_abundance <- as.data.frame(
    t(t(asv_counts_df) / colSums(asv_counts_df))
  )

  # 1.2 Calculate overall average relative abundance for each ASV across all samples
  asv_overall_avg_rel_abundance <- rowMeans(relative_abundance)

  # 1.3 Identify ASVs present in enough groups (only if metadata is provided)
  if (!is.null(metadata_df) && !is.null(group_column_name)) {
    # Check if group column exists
    if (!group_column_name %in% colnames(metadata_df)) {
      stop(paste0("Error: The specified group column '", group_column_name, "' was not found in the metadata. Please check the column name."))
    }
    if (!is.data.frame(metadata_df) || is.null(rownames(metadata_df))) {
      stop("If `metadata_df` is provided, it must be a data frame with non-NULL row names (which should be sample IDs).")
    }

    # Convert absolute abundance table to long format and add Group information
    # Explicitly call reshape2::melt() to avoid conflicts
    b_abs_long <- reshape2::melt(as.matrix(asv_counts_df), varnames = c("ASV", "Sample"))

    # Get the mapping of samples to the specified group column
    sample_Groups <- metadata_df[[group_column_name]]
    names(sample_Groups) <- rownames(metadata_df) # Use row names as sample IDs

    # Ensure sample IDs in long-format data match metadata sample IDs
    b_abs_long$Group <- sample_Groups[match(b_abs_long$Sample, names(sample_Groups))]

    # Check for unmatched samples, though usually phyloseq processing ensures a match
    if (any(is.na(b_abs_long$Group))) {
      warning("Warning: Some samples in the metadata could not be matched with corresponding group information. This might be due to mismatched sample IDs.")
    }

    # Filter out records where ASV count is > 0, and count how many unique Groups each ASV appears in
    asv_group_presence_count <- b_abs_long %>%
      dplyr::filter(value > 0, !is.na(Group)) %>% # Keep only records where ASV count > 0 and Group is not NA
      dplyr::group_by(ASV) %>%
      dplyr::summarise(unique_groups_present = dplyr::n_distinct(Group), .groups = "drop")

    # Filter for ASV names that meet the minimum group presence requirement
    asvs_in_enough_groups <- asv_group_presence_count$ASV[
      asv_group_presence_count$unique_groups_present >= min_groups_present
    ]
  } else {
    # If no metadata_df or group_column_name is provided, all ASVs are considered to meet group presence
    asvs_in_enough_groups <- rownames(asv_counts_df)
    message("No `metadata_df` or `group_column_name` provided; skipping group-based filtering.")
  }

  # --- Step 2: Apply all filtering conditions ---

  # Initialize a logical vector to mark which ASVs meet all conditions
  asv_to_keep_final <- rep(FALSE, nrow(asv_counts_df))
  names(asv_to_keep_final) <- rownames(asv_counts_df) # Ensure vector has row names for lookup

  # Iterate through each ASV
  for (asv_name in rownames(asv_counts_df)) {
    i <- which(rownames(asv_counts_df) == asv_name) # Get row index of current ASV

    current_asv_abs_counts <- asv_counts_df[i, ] # Absolute abundance data for current ASV

    # Condition 1: ASV present in at least min_samples_present samples (absolute abundance > 0)
    samples_where_present <- sum(current_asv_abs_counts > 0)

    # Condition 2: ASV absolute abundance > min_abs_abundance_value in at least min_samples_present samples
    samples_high_abs_abundance <- sum(current_asv_abs_counts >= min_abs_abundance_value)

    # Condition 3: Is ASV in the list of ASVs that meet group presence conditions (from Step 1)
    is_in_enough_groups <- (asv_name %in% asvs_in_enough_groups)

    # Condition 4: ASV overall average relative abundance > min_overall_avg_rel_abundance
    is_high_overall_avg_rel_abundance <- (asv_overall_avg_rel_abundance[asv_name] >= min_overall_avg_rel_abundance)

    # Check if all four conditions are met
    if (samples_where_present >= min_samples_present &&
        samples_high_abs_abundance >= min_samples_present &&
        is_in_enough_groups && # Group presence condition (TRUE if no metadata provided)
        is_high_overall_avg_rel_abundance) {
      asv_to_keep_final[i] <- TRUE # If all conditions met, keep this ASV
    }
  }

  # --- Step 3: Filter ASVs based on final conditions ---
  filtered_asv_counts_final <- asv_counts_df[asv_to_keep_final, ]

  # Print number of filtered results
  message(paste0("After filtering by multiple criteria, ", nrow(filtered_asv_counts_final), " ASVs were retained."))

  return(filtered_asv_counts_final)
}
