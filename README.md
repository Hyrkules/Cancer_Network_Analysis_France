
# Cancer Network Analysis in French Departments

This project explores the cancer incidence across French departments, analyzing the distribution of cancer cases relative to population size and visualizing the results using social network analysis techniques. By applying centrality metrics, we aim to identify regional clusters and key departments with similar cancer prevalence patterns.

## Problem Statement

The main research question is: **Which departments in France have similar cancer incidence rates, and how do these patterns evolve over time?**

## Data Sources

We use two datasets:
1. **Cancer Data**: Sourced from the French social security website, containing patient counts by pathology, sex, age, and region. For this analysis, only cancer data has been extracted, covering multiple years and including information such as department, year, and cancer cases.
   
   [Dataset link](https://data.ameli.fr/explore/dataset/effectifs/export/)
   
2. **Population Data**: Population by department dataset from INSEE, filtered for 2020, providing a reference for calculating cancer incidence rates relative to the population.

   [Dataset link](https://www.insee.fr/fr/statistiques/2012713#tableau-TCRD_004_tab1_departements)

## Methodology

1. **Data Filtering**: The cancer dataset is filtered to retain only cancer cases (`patho_niv1 = "Cancers"`). Non-essential columns are removed.
   
2. **Year-wise Analysis**: The data is split by year to observe temporal changes in cancer incidence across departments.
   
3. **Cancer Incidence Calculation**: The ratio of cancer cases to the population is computed for each department. Departments are compared based on these ratios, and an adjacency matrix is constructed to form networks where significant differences in cancer ratios are highlighted.
   
4. **Threshold for Similarity**: A threshold difference in cancer ratios is applied to filter meaningful relationships between departments, with the threshold being adjustable (default: 0.002).

5. **Graph Construction**: Networks are created for each year using the **igraph** package, where departments are nodes and edges represent similar cancer rates.
   
6. **Centrality Metrics**: Various centrality measures are applied to analyze the role of each department in the network:
   - **Degree Centrality**: Number of direct connections.
   - **Closeness Centrality**: How quickly a department can access others.
   - **Betweenness Centrality**: Importance as a bridge between departments.
   - **Eigenvector Centrality**: Influence within the network.

## Results and Visualizations

- Network graphs are generated for each year, showcasing departmental relationships based on cancer incidence ratios.
- Centrality metrics are included in the graphs to identify key departments in terms of influence or similarity.

## Conclusion

From the analysis, certain departments, like **Drôme (26)**, show central positions in the network, indicating that they have similar cancer incidence rates to many other departments. These insights could be valuable for regional health planning or medical studies targeting similar regions.

## Future Work

- The analysis currently focuses on "Cancers" as the primary pathology. Expanding to include more specific cancer types (e.g., breast, lung) or other diseases could provide more granular insights.
- Threshold adjustments and including more population dynamics over time could further refine the model.

## Code

The project is implemented in **R**, using `readr`, `dplyr`, and `igraph` packages for data manipulation and network analysis.
