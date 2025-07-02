#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
#' @importFrom dplyr filter group_by n_distinct select summarise
#' @importFrom magrittr %>%
#' @importFrom reshape2 melt
## usethis namespace: end
NULL

# --- Define Global Variables to Suppress 'no visible binding for global variable' Notes ---
# This line is crucial for R CMD check, telling it that these variables
# (commonly column names in dplyr operations) are expected to be global.
utils::globalVariables(c("ASV", "Group", "value"))
