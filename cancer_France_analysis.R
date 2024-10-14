library(readr)
library(dplyr)
library(igraph)

# Load data
df <- read.csv("effectifs.csv",
               na.strings = c("", "NA"),
               header = TRUE,
               sep = ";")
#load the second data
population_dep <- read.csv(file = "test_rstudio_dep.csv",
                           sep = ";", header=TRUE)
# Filter data by cancer
df <- subset(df, patho_niv1 == "Cancers")
# Drop unnecessary columns
drops <- c("top", "cla_age_5", "sexe", "region", "npop", "prev", "niveau_prioritaire", "libelle_classe_age", "libelle_sexe")
df_clean <- select(df, -one_of(drops))
# Split data by year
df_list <- split(df_clean, df_clean$annee - 2014)
# Define function to process data for each year
process_year <- function(df_year, population_dep, threshold_diff) {
  # Create a table of department and case of cancers
  count_by_dept <- table(df_year$dept)
  # Merge with the population data to get the population of each department
  # Set `all.x` to TRUE to keep all departments even if there are no cases
  table_dept <- data.frame(num_dep = names(count_by_dept), freq = count_by_dept)
  table_merged <- merge(population_dep, table_dept, by = "num_dep", all.x = TRUE)
  # Clean the population data by removing spaces and converting to numeric
  table_merged$X2020 <- as.numeric(gsub(" ", "", table_merged$X2020))
  table_merged$X2020 <- as.numeric(table_merged$X2020)
  # Remove rows with missing values
  table_merged <- na.omit(table_merged)
  # Calculate the ratio of cancer cases per population for each department
  table_merged$ratio <- table_merged$freq.Freq / table_merged$X2020
  # Filter the departments based on the given threshold for difference in ratios
  df_filtered <- table_merged[table_merged$ratio >= threshold_diff, ]
  df_filtered <- na.omit(df_filtered)
  # Create all possible pairs of departments and calculate the differences in ratios
  combs <- expand.grid(df_filtered$num_dep, df_filtered$num_dep)
  diffs <- abs(outer(df_filtered$ratio, df_filtered$ratio, "-"))
  # Set differences below the threshold to 0
  diffs[diffs < threshold_diff] <- 0
  # Create an adjacency matrix based on the differences above the threshold
  adj_mat <- ifelse(diffs > 0, 1, 0)
  # Create an undirected graph from the adjacency matrix
  graph <- graph.adjacency(adj_mat, mode = "undirected")
  # Set the vertex names and labels
  graph <- set_vertex_attr(graph, "name", value = df_filtered$num_dep)
  graph <- set_vertex_attr(graph, "label", value = df_filtered$num_dep)
  # Store the resulting table and graph in a list
  result_list <- list(table_merged = table_merged, graph = graph)
  return(result_list)
}
# Adding the threshold value
threshold_diff <- 0.002
# Calling process_year function
result_list <- lapply(df_list, process_year, population_dep = population_dep, threshold_diff = threshold_diff)

# Plot the graphs
for (i in seq_along(result_list)) {
  # Get the year from the list index
  year <- as.numeric(names(df_list)[i]) + 2014
  # Get the igraph object from the result list
  g <- result_list[[i]]$graph
  # Set the vertex names and labels
  V(g)$name <- result_list[[i]]$table_merged$num_dep
  V(g)$label <- result_list[[i]]$table_merged$num_dep
  # Plot the graph with the year as the title
  degree_centrality <- degree(g)
  closeness_centrality <- round(closeness(g),5)
  betweenness_centrality <- round(betweenness(g),5)
  eigenvector_centrality <- round(eigen_centrality(g)$vector,5)
  
  V(g)$degree_centrality <- degree_centrality
  V(g)$betweenness_centrality <- betweenness_centrality
  V(g)$closeness_centrality <- closeness_centrality
  V(g)$eigenvector_centrality <- eigenvector_centrality
  # Code pour générer le plot avec des étiquettes réduites
  #V(g)$label <- paste(V(g)$name, "\nDeg: ", degree_centrality, "\nbcent: ", betweenness_centrality)
  V(g)$label <- paste(V(g)$name, "\nbclo: ", closeness_centrality, "\nbeig: ", eigenvector_centrality)
  plot(g, vertex.label = V(g)$label, vertex.label.cex = 0.5, vertex.size=22,vertex.label.dist=0,5,main = paste0("Cancer Network ", year))
  
}
