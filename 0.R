# Setup API keys
#
# CrowdTangle (required)
#
# CooRnet requires a CrowdTangle API key entry in your R environment file. The R environment file is loaded every time R is started/restarted.
#
# The following steps show how to add the key to your R environment file.
#
# Open your .Renviron file. The file is usually located in your home directory. If the file does not exist, just create one and name it .Renviron.
# Add a new line and enter your API key in the following format: CROWDTANGLE_API_KEY=“YOUR_API_KEY”.
# Save the file and restart your current R session to start using CooRnet.
#
# NewsGuard (optional)
#
# Optionally, you can also set your credential to access NewsGuard API. The integration returns the average NewsGuard rating score obtained by the domains shared by a coordinated network.
#
# This process requires an active subscription to NewsGuard API and key entries in your R environment file. The R environment file is loaded every time R is started/restarted.
#
# The following steps show how to add the key to your R environment file.
#
# Open your .Renviron file. The file is usually located in your home directory. If the file does not exist, just create one and name it .Renviron.
#
# Add two new line and enter your API key in the following format: NG_KEY=“YOUR_API_KEY” NG_SECRET=“YOUR_API_SECRET”
# Save the file and restart your current R session to start using CooRnet.

install.packages("devtools")
library("devtools")
devtools::install_github("fabiogiglietto/CooRnet")

library("readr")
library("CooRnet")

# set the link to CrowdTangle CSV file
allpostsfile <- "https://github.com/fabiogiglietto/CooRnet_at_DMI_WS_2023/blob/main/rawdata/allposts.csv?raw=true"

# un-comment the following lines if you want to inspect the CSV file
# df <- readr::read_csv(allpostsfile)
# names(df)
# head(df)

urls <- CooRnet::get_urls_from_ct_histdata(ct_histdata_csv = allpostsfile,
                                           newformat = TRUE)

nrow(urls) # get the number of URLs
names(urls) # list the columns name
write.csv(urls, "./data/urls.csv") # save the list of URLs on disk

ct_shares.urls <- CooRnet::get_ctshares(urls,
                                        sleep_time = 1,
                                        get_history = FALSE,
                                        clean_urls = TRUE)

# un-comment the following line to load the rds file from disk
# ct_shares.urls <- readRDS("./data/ct_shares.rds")

nrow(ct_shares.urls) # 1,128,826 posts
saveRDS(ct_shares.urls, "./data/ct_shares.rds") # save the posts on disk

CooRnet::estimate_coord_interval(ct_shares.df = ct_shares.urls) # 23 secs

### 0.995
dir.create("./data/995_23")

output <- CooRnet::get_coord_shares(ct_shares.df = ct_shares.urls,
                                    coordination_interval = "23 secs",
                                    parallel = FALSE,
                                    percentile_edge_weight = 0.995,
                                    keep_ourl_only = TRUE,
                                    clean_urls = TRUE)

# un-comment the following line to load the output file from disk
# output <- readRDS("./data/995_23/output.rds")

saveRDS(output, "./data/995_23/output.rds")

# extract the different elements of the outputs
CooRnet::get_outputs(coord_shares_output = output,
                     component_summary = TRUE,
                     cluster_summary = TRUE,
                     top_coord_shares = TRUE,
                     top_coord_urls = TRUE)

# save highly_connected_coordinated_entities in .CSV format for further analysis
readr::write_csv(highly_connected_coordinated_entities, file = "./data/995_23/highly_connected_coordinated_entities.csv")

# save component summary in .CSV format for further analysis
readr::write_csv(component_summary, file = "./data/995_23/component_summary.csv")

# save cluster summary in .CSV format for further analysis
readr::write_csv(cluster_summary, file = "./data/995_23/cluster_summary.csv")

# save component summary in .CSV format for further analysis
readr::write_csv(top_coord_urls, file = "./data/995_23/top_coord_urls.csv")

# save cluster summary in .CSV format for further analysis
readr::write_csv(top_coord_shares, file = "./data/995_23/top_coord_shares.csv")

# save highly_connected_g in .GRAPHML format for further analysis with Gephi or similar software
library("igraph")
igraph::write.graph(highly_connected_g, file = "./data/995_23/highly_connected_g.graphml", format = "graphml")
