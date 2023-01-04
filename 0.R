library("devtools")
library("readr")
library("CooRnet")

# un-comment the following lines if you want to inspect the CSV file
# df <- read.csv("./rawdata/allposts.csv")
# names(df)
# head(df)

urls <- CooRnet::get_urls_from_ct_histdata(ct_histdata_csv = allposts_csv_link,
                                           newformat = TRUE)

nrow(urls) # get the number of URLs
write.csv(urls, "urls.csv") # save the list of URLs on disk

ct_shares.urls <- get_ctshares(urls,
                               sleep_time = 0.075,
                               get_history = FALSE,
                               clean_urls = TRUE)

saveRDS(ct_shares.urls, "./data/ct_shares.rds")

library(googledrive)
drive_upload("./data/ct_shares.rds", as_id("18Y-bGbhNx8Srg-RMIl724tiRNwIK59By"))

CooRnet::estimate_coord_interval(ct_shares.df = ct_shares.urls) # 23 secs

### 0.995

output <- CooRnet::get_coord_shares(ct_shares.df = ct_shares.urls,
                                    coordination_interval = "23 secs",
                                    parallel = FALSE,
                                    percentile_edge_weight = 0.99,
                                    keep_ourl_only = TRUE,
                                    clean_urls = TRUE)

saveRDS(output, "./data/output_099_23.rds")

CooRnet::get_outputs(coord_shares_output = output,
                     component_summary = TRUE,
                     cluster_summary = TRUE,
                     top_coord_urls = TRUE,
                     gdrive_folder_id = "1_jnUUcMekX9sijzhqlUEnKHwS5cuuR7M")

###

output <- CooRnet::get_coord_shares(ct_shares.df = ct_shares.urls,
                                    coordination_interval = "23 secs",
                                    parallel = FALSE,
                                    percentile_edge_weight = 0.995,
                                    keep_ourl_only = TRUE,
                                    clean_urls = TRUE)

saveRDS(output, "./data/output_0995_23.rds")

CooRnet::get_outputs(coord_shares_output = output,
                     component_summary = TRUE,
                     cluster_summary = TRUE,
                     top_coord_urls = TRUE,
                     gdrive_folder_id = "1iCi2ec5DOQUaBMsf4Z1e0VtYBDm5e5h0")
