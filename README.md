
# asvtools

The goal of asvtools is to provide a robust and flexible way to filter
Amplicon Sequence Variants (ASVs) based on multiple biological and
statistical criteria, which is a common and crucial step in microbiome
data analysis.

## Installation

You can install the development version of **asvtools** from
[GitHub](https://github.com/GaoYangxx/asvtools) with:

``` r
# install.packages("devtools")
devtools::install_github("GaoYangxx/asvtools")
#> Using GitHub PAT from the git credential store.
#> Downloading GitHub repo GaoYangxx/asvtools@HEAD
#> 
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#>          checking for file 'C:\Users\Gao Yang\AppData\Local\Temp\RtmpSSzSAg\remotes7e38d1b39b6\GaoYangxx-asvtools-25f30aa/DESCRIPTION' ...  ✔  checking for file 'C:\Users\Gao Yang\AppData\Local\Temp\RtmpSSzSAg\remotes7e38d1b39b6\GaoYangxx-asvtools-25f30aa/DESCRIPTION'
#>       ─  preparing 'asvtools':
#>    checking DESCRIPTION meta-information ...     checking DESCRIPTION meta-information ...   ✔  checking DESCRIPTION meta-information
#>       ─  checking for LF line-endings in source and make files and shell scripts
#>   ─  checking for empty or unneeded directories
#>       ─  building 'asvtools_0.0.0.9000.tar.gz'
#>      
#> 
#> Installing package into 'C:/Users/Gao Yang/AppData/Local/Temp/Rtmpo94r89/temp_libpath7a8c291a1b96'
#> (as 'lib' is unspecified)
library(asvtools) # load the package
```

## Usage

The filter_asvs() function is designed to apply a series of common
filtering steps to ASV count data. It allows for highly customizable
filtering based on absolute abundance, relative abundance, and presence
across samples and biological groups.

### `filter_asvs()` Function Overview

This function filters ASVs based on four conditions, which can be
combined or used individually:

1.Minimum Sample Presence (Absolute Abundance \> 0): An ASV must be
detected (count \> 0) in at least min_samples_present samples.

2.Minimum Absolute Abundance Value: In at least min_samples_present
samples, the ASV’s absolute count must be greater than or equal to
min_abs_abundance_value. Note that min_samples_present applies to both
the “count \> 0” and “count \>= value” criteria.

3.(Optional) Minimum Group Presence: If metadata_df and
group_column_name are provided, an ASV must be present (absolute
abundance \> 0) in at least min_groups_present distinct biological
groups defined by the specified column in the metadata.

4.Minimum Overall Average Relative Abundance: The ASV’s average relative
abundance across all samples must be greater than or equal to
min_overall_avg_rel_abundance.

``` r
# --- Create dummy ASV count data ---
# This small example data allows for clear demonstration of filtering effects.
# Note: In a real scenario, you would load your actual ASV table and metadata.
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

# --- Create dummy metadata ---
metadata <- data.frame(
  Sample.ID = c("JRG_1", "JRG_2", "JRG_3", "JRG_4", "JRG_5", "JRG_6", "JJG_1", "JJG_2", "JJG_3", "JJG_4", "JJG_5", "JJG_6", "TZG_1", "TZG_2", "TZG_3", "TZG_4", "TZG_5", "TZG_6", "PAG_1", "PAG_2", "PAG_3", "PAG_4", "PAG_5", "PAG_6"),
  Group = c("JRG", "JRG", "JRG", "JRG", "JRG", "JRG", "JJG", "JJG", "JJG", "JJG", "JJG", "JJG", "TZG", "TZG", "TZG", "TZG", "TZG", "TZG", "PAG", "PAG", "PAG", "PAG", "PAG", "PAG"),
  Origin = c("JR", "JR", "JR", "JR", "JR", "JR", "JJ", "JJ", "JJ", "JJ", "JJ", "JJ", "TZ", "TZ", "TZ", "TZ", "TZ", "TZ", "PA", "PA", "PA", "PA", "PA", "PA"),
  Niche = c("G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G", "G"),
  row.names = c("JRG_1", "JRG_2", "JRG_3", "JRG_4", "JRG_5", "JRG_6", "JJG_1", "JJG_2", "JJG_3", "JJG_4", "JJG_5", "JJG_6", "TZG_1", "TZG_2", "TZG_3", "TZG_4", "TZG_5", "TZG_6", "PAG_1", "PAG_2", "PAG_3", "PAG_4", "PAG_5", "PAG_6"),
  stringsAsFactors = FALSE # Important for character columns
)
```

### Example 1: Basic Filtering by Sample Presence and Absolute Abundance

Let’s filter for ASVs present in at least 3 samples, with an absolute
abundance of at least 5 in those samples.

``` r
library(asvtools)

filtered_asvs_basic <- filter_asvs(
  asv_counts_df = ASVs,
  min_samples_present = 3,
  min_abs_abundance_value = 5
)
#> No `metadata_df` or `group_column_name` provided; skipping group-based filtering.
#> After filtering by multiple criteria, 20 ASVs were retained.
print("Filtered ASVs (min_samples_present=3, min_abs_abundance_value=5):")
#> [1] "Filtered ASVs (min_samples_present=3, min_abs_abundance_value=5):"
print(filtered_asvs_basic)
#>          JRG_1 JRG_2 JRG_3 JRG_4 JRG_5 JRG_6 JJG_1 JJG_2 JJG_3 JJG_4 JJG_5
#> ASV201      16    23    36    27     0    21    38    25    41    31    24
#> ASV138       0     0    12     0     0     0    49    64    45    56    32
#> ASV11736     0     0     0    83     0     0     0     0     0     0     0
#> ASV207       0     0     5     0     0     0     0     0    41    15     0
#> ASV323       0     0     0    27     0     0    25    26    30    24    66
#> ASV4139     18    29    46    25    50     0    28    31     0    37    55
#> ASV4011      0     0     0     0     0     0     0     0     0    15     0
#> ASV6667      0     0     0     0     0     0     0     0     0     0     0
#> ASV317       0     0     0     0     0     0    48    31    26    33    36
#> ASV11791    33    32     0    34     0     0     0    23     0    10     0
#> ASV712      33     0     0    37    43    21     9     8    11    13    12
#> ASV6543      0     0     0     0     0     0    18     0     0     0     0
#> ASV14       37    44    25    29    20     0   105   155   213    65   111
#> ASV6519      0     0     0     0     0     0     0     0     0    41     0
#> ASV3823      0     0     0     0     0     0     0     0     0     0     0
#> ASV3800      0     0     0     0     0     0     0    15     0    14     0
#> ASV5338      0     0     0     0     0     0     0     0     0     0     0
#> ASV105       0     0     0     0     0     0    44    52    59    37    62
#> ASV117      38    22    28    19    18    22    62    79    51    81    44
#> ASV337       0     0     0     0     0     0     9    16    24    19    30
#>          JJG_6 TZG_1 TZG_2 TZG_3 TZG_4 TZG_5 TZG_6 PAG_1 PAG_2 PAG_3 PAG_4
#> ASV201       0    36    35    39    50    53    43     0     0     0     0
#> ASV138      31    15    14    12    14     0    12     8     9     8    16
#> ASV11736     0     0     0   121     0   103     0     0     0     0     0
#> ASV207       0    50     0     0    31     0    32    34     0     0     0
#> ASV323      33     0     0     0     0     0     0     0     0     0     0
#> ASV4139     21    20     0    25    25     0     0     0     0     0     0
#> ASV4011      0     0    18    26    14     0     0     0    10     5     8
#> ASV6667      0    23    18    15    18    10    11    16     0     4     7
#> ASV317      25    16     0    26     0     0     0   122   122    79   428
#> ASV11791     0    20     0     0     0     0     0     0     0     0     0
#> ASV712       7     4     0     0     0     3     0     0     0     0     0
#> ASV6543     34     0    49     0     0     0     0     0     0     0     0
#> ASV14      102     0     0    76     0     0     0     0     0     0     0
#> ASV6519      0    35    61    87    43    63     0     0     0     0     0
#> ASV3823      0    25    52    37    25    32    29    23    27     0     0
#> ASV3800      0    30    24     0     0    24     0    25    21    41    38
#> ASV5338      5   224    88    61    66   142    60     0     0     0     0
#> ASV105      57     0    34     0     0    32     0     0     0     0     0
#> ASV117      37     0     0     0     0     0     0    34     0     0    15
#> ASV337      30    14    10     0    24     0    14     0     0     0     0
#>          PAG_5 PAG_6
#> ASV201       0     0
#> ASV138      11     9
#> ASV11736     0     0
#> ASV207       0    36
#> ASV323       0     0
#> ASV4139      0     0
#> ASV4011     11     9
#> ASV6667     18     0
#> ASV317     598   161
#> ASV11791     0     0
#> ASV712       0     0
#> ASV6543      0     0
#> ASV14        0     0
#> ASV6519      0     0
#> ASV3823      0    29
#> ASV3800     34    23
#> ASV5338      0     0
#> ASV105       0     0
#> ASV117       0    42
#> ASV337       0     0
```

### Example 2: Combining All Criteria, Including Group-based Filtering

Now, let’s add filtering by biological groups and overall relative
abundance. We want ASVs that meet:

1.Present in at least 3 samples (absolute abundance \> 0).

2.Absolute abundance \>= 5 in at least 3 samples.

3.Present in at least 2 distinct Groups.

4.Overall average relative abundance \>= 0.001 (0.1%).

``` r
library(asvtools)

filtered_asvs_full <- filter_asvs(
  asv_counts_df = ASVs,
  metadata_df = metadata,
  group_column_name = "Group",
  min_samples_present = 3,
  min_abs_abundance_value = 5,
  min_groups_present = 2, # Requires ASV presence in at least 2 distinct groups
  min_overall_avg_rel_abundance = 0.001 # Overall average relative abundance
)
#> After filtering by multiple criteria, 20 ASVs were retained.
print("Filtered ASVs (all combined criteria):")
#> [1] "Filtered ASVs (all combined criteria):"
print(filtered_asvs_full)
#>          JRG_1 JRG_2 JRG_3 JRG_4 JRG_5 JRG_6 JJG_1 JJG_2 JJG_3 JJG_4 JJG_5
#> ASV201      16    23    36    27     0    21    38    25    41    31    24
#> ASV138       0     0    12     0     0     0    49    64    45    56    32
#> ASV11736     0     0     0    83     0     0     0     0     0     0     0
#> ASV207       0     0     5     0     0     0     0     0    41    15     0
#> ASV323       0     0     0    27     0     0    25    26    30    24    66
#> ASV4139     18    29    46    25    50     0    28    31     0    37    55
#> ASV4011      0     0     0     0     0     0     0     0     0    15     0
#> ASV6667      0     0     0     0     0     0     0     0     0     0     0
#> ASV317       0     0     0     0     0     0    48    31    26    33    36
#> ASV11791    33    32     0    34     0     0     0    23     0    10     0
#> ASV712      33     0     0    37    43    21     9     8    11    13    12
#> ASV6543      0     0     0     0     0     0    18     0     0     0     0
#> ASV14       37    44    25    29    20     0   105   155   213    65   111
#> ASV6519      0     0     0     0     0     0     0     0     0    41     0
#> ASV3823      0     0     0     0     0     0     0     0     0     0     0
#> ASV3800      0     0     0     0     0     0     0    15     0    14     0
#> ASV5338      0     0     0     0     0     0     0     0     0     0     0
#> ASV105       0     0     0     0     0     0    44    52    59    37    62
#> ASV117      38    22    28    19    18    22    62    79    51    81    44
#> ASV337       0     0     0     0     0     0     9    16    24    19    30
#>          JJG_6 TZG_1 TZG_2 TZG_3 TZG_4 TZG_5 TZG_6 PAG_1 PAG_2 PAG_3 PAG_4
#> ASV201       0    36    35    39    50    53    43     0     0     0     0
#> ASV138      31    15    14    12    14     0    12     8     9     8    16
#> ASV11736     0     0     0   121     0   103     0     0     0     0     0
#> ASV207       0    50     0     0    31     0    32    34     0     0     0
#> ASV323      33     0     0     0     0     0     0     0     0     0     0
#> ASV4139     21    20     0    25    25     0     0     0     0     0     0
#> ASV4011      0     0    18    26    14     0     0     0    10     5     8
#> ASV6667      0    23    18    15    18    10    11    16     0     4     7
#> ASV317      25    16     0    26     0     0     0   122   122    79   428
#> ASV11791     0    20     0     0     0     0     0     0     0     0     0
#> ASV712       7     4     0     0     0     3     0     0     0     0     0
#> ASV6543     34     0    49     0     0     0     0     0     0     0     0
#> ASV14      102     0     0    76     0     0     0     0     0     0     0
#> ASV6519      0    35    61    87    43    63     0     0     0     0     0
#> ASV3823      0    25    52    37    25    32    29    23    27     0     0
#> ASV3800      0    30    24     0     0    24     0    25    21    41    38
#> ASV5338      5   224    88    61    66   142    60     0     0     0     0
#> ASV105      57     0    34     0     0    32     0     0     0     0     0
#> ASV117      37     0     0     0     0     0     0    34     0     0    15
#> ASV337      30    14    10     0    24     0    14     0     0     0     0
#>          PAG_5 PAG_6
#> ASV201       0     0
#> ASV138      11     9
#> ASV11736     0     0
#> ASV207       0    36
#> ASV323       0     0
#> ASV4139      0     0
#> ASV4011     11     9
#> ASV6667     18     0
#> ASV317     598   161
#> ASV11791     0     0
#> ASV712       0     0
#> ASV6543      0     0
#> ASV14        0     0
#> ASV6519      0     0
#> ASV3823      0    29
#> ASV3800     34    23
#> ASV5338      0     0
#> ASV105       0     0
#> ASV117       0    42
#> ASV337       0     0
```

### Example 3: Skipping Group-based Filtering

If you do not provide metadata_df or group_column_name, the group-based
filtering criterion is skipped, and a message will be displayed.

``` r
library(asvtools)

filtered_asvs_no_group <- filter_asvs(
  asv_counts_df = ASVs,
  min_samples_present = 3,
  min_abs_abundance_value = 5,
  min_overall_avg_rel_abundance = 0.001
)
#> No `metadata_df` or `group_column_name` provided; skipping group-based filtering.
#> After filtering by multiple criteria, 20 ASVs were retained.
print("Filtered ASVs (no group filtering):")
#> [1] "Filtered ASVs (no group filtering):"
print(filtered_asvs_no_group)
#>          JRG_1 JRG_2 JRG_3 JRG_4 JRG_5 JRG_6 JJG_1 JJG_2 JJG_3 JJG_4 JJG_5
#> ASV201      16    23    36    27     0    21    38    25    41    31    24
#> ASV138       0     0    12     0     0     0    49    64    45    56    32
#> ASV11736     0     0     0    83     0     0     0     0     0     0     0
#> ASV207       0     0     5     0     0     0     0     0    41    15     0
#> ASV323       0     0     0    27     0     0    25    26    30    24    66
#> ASV4139     18    29    46    25    50     0    28    31     0    37    55
#> ASV4011      0     0     0     0     0     0     0     0     0    15     0
#> ASV6667      0     0     0     0     0     0     0     0     0     0     0
#> ASV317       0     0     0     0     0     0    48    31    26    33    36
#> ASV11791    33    32     0    34     0     0     0    23     0    10     0
#> ASV712      33     0     0    37    43    21     9     8    11    13    12
#> ASV6543      0     0     0     0     0     0    18     0     0     0     0
#> ASV14       37    44    25    29    20     0   105   155   213    65   111
#> ASV6519      0     0     0     0     0     0     0     0     0    41     0
#> ASV3823      0     0     0     0     0     0     0     0     0     0     0
#> ASV3800      0     0     0     0     0     0     0    15     0    14     0
#> ASV5338      0     0     0     0     0     0     0     0     0     0     0
#> ASV105       0     0     0     0     0     0    44    52    59    37    62
#> ASV117      38    22    28    19    18    22    62    79    51    81    44
#> ASV337       0     0     0     0     0     0     9    16    24    19    30
#>          JJG_6 TZG_1 TZG_2 TZG_3 TZG_4 TZG_5 TZG_6 PAG_1 PAG_2 PAG_3 PAG_4
#> ASV201       0    36    35    39    50    53    43     0     0     0     0
#> ASV138      31    15    14    12    14     0    12     8     9     8    16
#> ASV11736     0     0     0   121     0   103     0     0     0     0     0
#> ASV207       0    50     0     0    31     0    32    34     0     0     0
#> ASV323      33     0     0     0     0     0     0     0     0     0     0
#> ASV4139     21    20     0    25    25     0     0     0     0     0     0
#> ASV4011      0     0    18    26    14     0     0     0    10     5     8
#> ASV6667      0    23    18    15    18    10    11    16     0     4     7
#> ASV317      25    16     0    26     0     0     0   122   122    79   428
#> ASV11791     0    20     0     0     0     0     0     0     0     0     0
#> ASV712       7     4     0     0     0     3     0     0     0     0     0
#> ASV6543     34     0    49     0     0     0     0     0     0     0     0
#> ASV14      102     0     0    76     0     0     0     0     0     0     0
#> ASV6519      0    35    61    87    43    63     0     0     0     0     0
#> ASV3823      0    25    52    37    25    32    29    23    27     0     0
#> ASV3800      0    30    24     0     0    24     0    25    21    41    38
#> ASV5338      5   224    88    61    66   142    60     0     0     0     0
#> ASV105      57     0    34     0     0    32     0     0     0     0     0
#> ASV117      37     0     0     0     0     0     0    34     0     0    15
#> ASV337      30    14    10     0    24     0    14     0     0     0     0
#>          PAG_5 PAG_6
#> ASV201       0     0
#> ASV138      11     9
#> ASV11736     0     0
#> ASV207       0    36
#> ASV323       0     0
#> ASV4139      0     0
#> ASV4011     11     9
#> ASV6667     18     0
#> ASV317     598   161
#> ASV11791     0     0
#> ASV712       0     0
#> ASV6543      0     0
#> ASV14        0     0
#> ASV6519      0     0
#> ASV3823      0    29
#> ASV3800     34    23
#> ASV5338      0     0
#> ASV105       0     0
#> ASV117       0    42
#> ASV337       0     0
```

## Error Handling

The function includes checks for common input issues:

1.asv_counts_df must be a data frame with non-NULL row and column names.

2.If metadata_df is provided, it must be a data frame with non-NULL row
names (which are expected to be sample IDs) and at least one column.

3.If group_column_name is provided, it must exist in metadata_df.

4.A warning will be issued if some samples in asv_counts_df columns
cannot be matched to metadata_df row names.

### Parameters

| Argument | Description |
|----|----|
| `asv_counts_df` | A data frame of ASV counts (rows = ASVs, columns = samples). |
| `metadata_df` | Optional. Metadata with sample info. |
| `group_column_name` | Column name in metadata for biological grouping. |
| `min_samples_present` | Minimum number of samples an ASV must appear in. |
| `min_abs_abundance_value` | Minimum absolute count threshold per sample. |
| `min_groups_present` | Optional. Minimum number of groups ASV must appear in. |
| `min_overall_avg_rel_abundance` | Minimum overall average relative abundance. |
