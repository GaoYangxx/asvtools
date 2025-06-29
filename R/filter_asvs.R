# 确保你已安装并加载了 'dplyr' 和 'reshape2' 包
# install.packages(c("dplyr", "reshape2", "tibble", "phyloseq")) # 如果没有安装，请取消注释并运行
library(dplyr)
library(reshape2)
library(tibble)
library(phyloseq)

#' 根据多重条件筛选 ASV
#'
#' 此函数根据以下四个条件筛选 ASV：
#' 1. 在至少 `min_samples_present` 个样本中存在 (绝对丰度 > 0)。
#' 2. 在至少 `min_samples_present` 个样本中绝对丰度大于 `min_abs_abundance_value`。
#' 3. (可选) 在至少 `min_groups_present` 个指定 `Group` 列的 Group 中存在 (绝对丰度 > 0)。
#' 4. 该 ASV 在所有样本中的整体平均相对丰度大于 `min_overall_avg_rel_abundance`。
#'
#' @param asv_counts_df ASV 计数的数据框，行名为 ASV ID，列名为样本 ID。
#' @param metadata_df (可选) 样本元数据的数据框，行名为样本 ID。如果提供，
#'   将根据 `group_column_name` 进行分组筛选。默认值为 NULL。
#' @param group_column_name (可选) 字符型，`metadata_df` 中用作分组依据的列名。
#'   仅当 `metadata_df` 提供时有效。默认值为 NULL。
#' @param min_samples_present ASV 必须在至少多少个样本中出现（绝对丰度 > 0）。
#' @param min_abs_abundance_value ASV 在样本中绝对丰度需要大于的阈值。
#' @param min_groups_present ASV 必须在至少多少个 Group 中存在（绝对丰度 > 0）。
#' @param min_overall_avg_rel_abundance ASV 在所有样本中的整体平均相对丰度阈值。
#'
#' @return 一个经过筛选的 ASV 计数数据框，只包含符合所有条件的 ASV。
#' @export
#'
#' @examples
#' # 假设已经准备好 b_ASV 和 metadata_df (如前面示例所示)
#'
#' # 示例 1: 使用所有筛选条件 (包括分组)
#' # filtered_asvs_full <- filter_asvs(
#' #   asv_counts_df = b_ASV,
#' #   metadata_df = metadata_df,
#' #   group_column_name = "Group", # 假设元数据中有 'Group' 列
#' #   min_samples_present = 3,
#' #   min_abs_abundance_value = 3,
#' #   min_groups_present = 2,
#' #   min_overall_avg_rel_abundance = 0.0001
#' # )
#' # print(filtered_asvs_full)
#'
#' # 示例 2: 不使用分组筛选 (metadata_df 和 group_column_name 为 NULL)
#' # filtered_asvs_no_group <- filter_asvs(
#' #   asv_counts_df = b_ASV,
#' #   min_samples_present = 3,
#' #   min_abs_abundance_value = 3,
#' #   min_overall_avg_rel_abundance = 0.0001 # min_groups_present 会被忽略
#' # )
#' # print(filtered_asvs_no_group)
filter_asvs <- function(asv_counts_df, metadata_df = NULL, group_column_name = NULL,
                        min_samples_present = 0,
                        min_abs_abundance_value = 0,
                        min_groups_present = 0,
                        min_overall_avg_rel_abundance = 0) {

  #  检查输入数据
  if (!is.data.frame(asv_counts_df) || is.null(rownames(asv_counts_df)) || is.null(colnames(asv_counts_df))) {
    stop("`asv_counts_df` 必须是一个数据框，且行名和列名不能为空。")
  }

  #  第一步：计算相对丰度并识别在足够多 Group 中存在的 ASV

  # 1.1 计算每个样本内的相对丰度
  relative_abundance <- as.data.frame(
    t(t(asv_counts_df) / colSums(asv_counts_df))
  )

  # 1.2 计算每个 ASV 在所有样本中的整体平均相对丰度
  asv_overall_avg_rel_abundance <- rowMeans(relative_abundance)

  # 1.3 识别在足够多 Group 中存在的 ASV (仅当提供元数据时执行)
  if (!is.null(metadata_df) && !is.null(group_column_name)) {
    # 检查 Group 列是否存在
    if (!group_column_name %in% colnames(metadata_df)) {
      stop(paste0("错误：元数据中未找到指定的 Group 列 '", group_column_name, "'。请检查列名是否正确。"))
    }
    if (!is.data.frame(metadata_df) || is.null(rownames(metadata_df))) {
      stop("如果提供 `metadata_df`，它必须是一个数据框且行名不能为空 (应为样本 ID)。")
    }

    # 将绝对丰度表转换为长格式，并添加 Group 信息
    # 明确调用 reshape2::melt() 来避免冲突
    b_abs_long <- reshape2::melt(as.matrix(asv_counts_df), varnames = c("ASV", "Sample"))

    # 获取样本到指定 Group 列的映射
    sample_Groups <- metadata_df[[group_column_name]]
    names(sample_Groups) <- rownames(metadata_df) # 使用行名作为样本ID

    # 确保长格式数据中的样本ID与元数据中的样本ID匹配
    b_abs_long$Group <- sample_Groups[match(b_abs_long$Sample, names(sample_Groups))]

    # 检查是否有未匹配的样本，通常phyloseq处理后应该匹配，但以防万一
    if (any(is.na(b_abs_long$Group))) {
      warning("警告：部分样本在元数据中未能找到对应的 Group 信息。这可能是由于样本ID不匹配造成的。")
    }

    # 筛选出 ASV 存在 (计数 > 0) 的记录，并统计每个 ASV 出现在多少个独特的 Group 中
    asv_group_presence_count <- b_abs_long %>%
      filter(value > 0, !is.na(Group)) %>% # 只保留 ASV 计数大于 0 且 Group 非NA 的记录
      group_by(ASV) %>%
      summarise(unique_groups_present = n_distinct(Group), .groups = "drop")

    # 筛选出符合 Group 数量要求的 ASV 名称
    asvs_in_enough_groups <- asv_group_presence_count$ASV[
      asv_group_presence_count$unique_groups_present >= min_groups_present
    ]
  } else {
    # 如果没有提供 metadata_df 或 group_column_name，则所有 ASV 都视为满足 Group 存在条件
    asvs_in_enough_groups <- rownames(asv_counts_df)
    message("未提供 `metadata_df` 或 `group_column_name`，跳过基于 Group 的筛选。")
  }

  #  第二步：应用所有筛选条件

  # 初始化一个逻辑向量，用于标记哪些 ASV 符合所有条件
  asv_to_keep_final <- rep(FALSE, nrow(asv_counts_df))
  names(asv_to_keep_final) <- rownames(asv_counts_df) # 确保向量有行名，方便查找

  # 遍历每个 ASV
  for (asv_name in rownames(asv_counts_df)) {
    i <- which(rownames(asv_counts_df) == asv_name) # 获取当前 ASV 的行索引

    current_asv_abs_counts <- asv_counts_df[i, ] # 当前 ASV 的绝对丰度数据

    # 条件 1：ASV 在至少 min_samples_present 个样本中出现 (绝对丰度 > 0)
    samples_where_present <- sum(current_asv_abs_counts > 0)

    # 条件 2：ASV 在至少 min_samples_present 个样本中绝对丰度 > min_abs_abundance_value
    samples_high_abs_abundance <- sum(current_asv_abs_counts >= min_abs_abundance_value)

    # 条件 3：ASV 是否在满足 Group 存在条件的 ASV 列表中 (来自第一步的计算)
    is_in_enough_groups <- (asv_name %in% asvs_in_enough_groups)

    # 条件 4：ASV 在所有样本中的整体平均相对丰度 > min_overall_avg_rel_abundance
    is_high_overall_avg_rel_abundance <- (asv_overall_avg_rel_abundance[asv_name] >= min_overall_avg_rel_abundance)

    # 检查所有四个条件是否都满足
    if (samples_where_present >= min_samples_present &&
        samples_high_abs_abundance >= min_samples_present &&
        is_in_enough_groups && # Group 存在条件 (若未提供元数据则为 TRUE)
        is_high_overall_avg_rel_abundance) {
      asv_to_keep_final[i] <- TRUE # 如果所有条件都满足，则保留该 ASV
    }
  }

  #  第三步：筛选出符合最终条件的 ASV
  filtered_asv_counts_final <- asv_counts_df[asv_to_keep_final, ]

  # 打印筛选结果数量
  message(paste0("经过多重条件筛选后，保留了 ", nrow(filtered_asv_counts_final), " 个 ASV。"))

  return(filtered_asv_counts_final)
}
