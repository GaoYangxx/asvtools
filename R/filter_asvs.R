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
#' @param min_total_abundance Minimum total count (row sum) across all samples.
#'
#' @return Filtered ASV table as a data frame.
#' @export
#'
#' @examples
#' # filtered <- filter_asvs(b_ASV, metadata, "Group", 3, 4, 2, 0.0001, 10)
filter_asvs <- function(asv_counts_df,
                        metadata_df = NULL,
                        group_column_name = NULL,
                        min_samples_present = 0,
                        min_abs_abundance_value = 0,
                        min_groups_present = 0,
                        min_overall_avg_rel_abundance = 0,
                        min_total_abundance = 0) {

  # Input validation
  if (!is.data.frame(asv_counts_df) || is.null(rownames(asv_counts_df)) || is.null(colnames(asv_counts_df))) {
    stop("`asv_counts_df` must be a data frame with non-NULL row and column names.")
  }
  if (!is.null(metadata_df)) {
    if (!is.data.frame(metadata_df) || is.null(rownames(metadata_df))) {
      stop("`metadata_df` must be a data frame with non-NULL row names.")
    }
    if (!is.null(group_column_name) && !(group_column_name %in% colnames(metadata_df))) {
      stop(paste0("Group column '", group_column_name, "' not found in metadata."))
    }
  }

  # Relative abundance matrix
  col_total <- colSums(asv_counts_df)
  col_total[col_total == 0] <- 1  # Prevent division by 0
  relative_abundance <- t(t(asv_counts_df) / col_total)
  asv_overall_avg_rel_abundance <- rowMeans(relative_abundance)

  # ASVs in enough groups (if applicable)
  if (!is.null(metadata_df) && !is.null(group_column_name)) {
    long_df <- reshape2::melt(as.matrix(asv_counts_df), varnames = c("ASV", "Sample"))
    long_df$Group <- metadata_df[match(long_df$Sample, rownames(metadata_df)), group_column_name]
    group_counts <- long_df %>%
      dplyr::filter(value > 0, !is.na(Group)) %>%
      dplyr::group_by(ASV) %>%
      dplyr::summarise(groups_present = dplyr::n_distinct(Group), .groups = "drop")
    asvs_in_enough_groups <- group_counts$ASV[group_counts$groups_present >= min_groups_present]
  } else {
    asvs_in_enough_groups <- rownames(asv_counts_df)
    message("Group filtering skipped (metadata or group column not provided).")
  }

  # Filter logic
  keep_flags <- logical(nrow(asv_counts_df))
  names(keep_flags) <- rownames(asv_counts_df)

  for (i in seq_len(nrow(asv_counts_df))) {
    asv_name <- rownames(asv_counts_df)[i]
    row_vals <- asv_counts_df[i, ]

    # Conditions
    cond1 <- sum(row_vals > 0) >= min_samples_present
    cond2 <- sum(row_vals >= min_abs_abundance_value) >= min_samples_present
    cond3 <- asv_name %in% asvs_in_enough_groups
    cond4 <- asv_overall_avg_rel_abundance[asv_name] >= min_overall_avg_rel_abundance
    cond5 <- sum(row_vals) >= min_total_abundance

    if (cond1 && cond2 && cond3 && cond4 && cond5) {
      keep_flags[i] <- TRUE
    }
  }

  filtered_df <- asv_counts_df[keep_flags, , drop = FALSE]
  message("Retained ", nrow(filtered_df), " ASVs after applying all filtering conditions.")

  return(filtered_df)
}
