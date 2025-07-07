#' Filter ASVs Based on Multiple Criteria
#'
#' @description
#' This function filters ASVs based on multiple user-defined criteria:
#' \enumerate{
#' \item Total abundance across all samples ≥ `min_total_abundance`
#' \item Presence in ≥ `min_samples_present` samples
#' \item Abundance ≥ `min_abs_abundance_value` in ≥ `min_samples_present` samples
#' \item (Optional) Presence in ≥ `min_groups_present` groups (`metadata_df` and `group_column_name` required)
#' \item Overall average relative abundance ≥ `min_overall_avg_rel_abundance`
#' }
#'
#' @param asv_counts_df A data frame: rows = ASV IDs, columns = sample IDs (absolute abundances).
#' @param metadata_df Optional sample metadata (row names = sample IDs).
#' @param group_column_name Optional column name in metadata to use for group filtering.
#' @param min_samples_present Minimum number of samples in which an ASV must appear.
#' @param min_abs_abundance_value Threshold to consider ASV "present" in a sample.
#' @param min_groups_present Minimum number of distinct groups an ASV must appear in.
#' @param min_overall_avg_rel_abundance Minimum average relative abundance across all samples.
#'
#' @return Filtered ASV table as a data frame.
#' @export
#'
#' @examples
#' # filtered <- filter_asvs(b_ASV, metadata, "Group", 3, 4, 2, 0.0001, 10)
filter_asvs <- function(asv_counts_df, metadata_df = NULL, group_column_name = NULL,
                        min_samples_present = 0,
                        min_abs_abundance_value = 0,
                        min_groups_present = 0,
                        min_overall_avg_rel_abundance = 0) {
  # --- Validate asv_counts_df ---
  if (!is.data.frame(asv_counts_df) || nrow(asv_counts_df) == 0 || ncol(asv_counts_df) == 0 ||
      is.null(rownames(asv_counts_df)) || is.null(colnames(asv_counts_df))) {
    stop("`asv_counts_df` must be a non-empty data frame with row and column names.")
  }

  # --- Validate metadata_df ---
  if (!is.null(metadata_df)) {
    if (!is.data.frame(metadata_df) || nrow(metadata_df) == 0 || ncol(metadata_df) == 0 ||
        is.null(rownames(metadata_df))) {
      stop("If `metadata_df` is provided, it must be a non-empty data frame with row names.")
    }

    if (!is.null(group_column_name)) {
      if (!(group_column_name %in% colnames(metadata_df))) {
        stop(paste0("The specified group column '", group_column_name, "' was not found in the metadata. Please check the column name."))
      }
    }
  }

  # --- Step 1: Calculate relative abundance and group presence ---

  # 1.1 Relative abundance
  relative_abundance <- as.data.frame(
    t(t(asv_counts_df) / colSums(asv_counts_df))
  )
  asv_overall_avg_rel_abundance <- rowMeans(relative_abundance)

  # 1.2 Group presence (only if metadata and group column provided)
  if (!is.null(metadata_df) && !is.null(group_column_name)) {
    b_abs_long <- reshape2::melt(as.matrix(asv_counts_df), varnames = c("ASV", "Sample"))
    sample_Groups <- metadata_df[[group_column_name]]
    names(sample_Groups) <- rownames(metadata_df)

    b_abs_long$Group <- sample_Groups[match(b_abs_long$Sample, names(sample_Groups))]

    if (any(is.na(b_abs_long$Group))) {
      warning("Some samples in the metadata could not be matched to their corresponding group information.")
    }

    asv_group_presence_count <- b_abs_long %>%
      dplyr::filter(value > 0, !is.na(Group)) %>%
      dplyr::group_by(ASV) %>%
      dplyr::summarise(unique_groups_present = dplyr::n_distinct(Group), .groups = "drop")

    asvs_in_enough_groups <- asv_group_presence_count$ASV[
      asv_group_presence_count$unique_groups_present >= min_groups_present
    ]
  } else {
    asvs_in_enough_groups <- rownames(asv_counts_df)
    message("No `metadata_df` or `group_column_name` provided; skipping group-based filtering.")
  }

  # --- Step 2: Apply filtering ---
  asv_to_keep_final <- rep(FALSE, nrow(asv_counts_df))
  names(asv_to_keep_final) <- rownames(asv_counts_df)

  for (asv_name in rownames(asv_counts_df)) {
    current_asv <- asv_counts_df[asv_name, ]
    samples_present <- sum(current_asv > 0)
    samples_above_threshold <- sum(current_asv >= min_abs_abundance_value)
    is_in_enough_groups <- asv_name %in% asvs_in_enough_groups
    is_high_avg_rel_abundance <- asv_overall_avg_rel_abundance[asv_name] >= min_overall_avg_rel_abundance

    if (samples_present >= min_samples_present &&
        samples_above_threshold >= min_samples_present &&
        is_in_enough_groups &&
        is_high_avg_rel_abundance) {
      asv_to_keep_final[asv_name] <- TRUE
    }
  }

  filtered_asvs <- asv_counts_df[asv_to_keep_final, , drop = FALSE]
  message("Retained ", nrow(filtered_asvs), " ASVs after applying all filtering conditions.")
  return(filtered_asvs)
}
