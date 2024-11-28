# Joon_2024PittCodingChallenge
This repository contains an analysis of HAM depression scale data for participants in the  Longitudinal Research Program in Late-Life Suicide studies.

## Requirements
- PDF of assignment description "CodingChallenge2024.pdf"
- R with `dplyr`, `tidyverse`, and `ggplot2` libraries
- Data file `CodeChallenge2024.RData` containing data necessary for assignment
- Text file containing list of relevant participant IDs "IDs.txt"

## Steps
1. Read and understand assignment details from "CodingChallenge2024.pdf"
2. Download `CodeChallenge2024.RData` and "IDs.txt"
3. Run `JoonLee2024PittCodingAssignment.R` in RStudio
4. Outputs will be saved in the working directory

## Output Files
- **final_df.csv**: Cleaned data frame containing participant HAM scores
- **total_participants_chart.png**: Bar graph showing participant counts by recruitment source
- **gender_chart.png**: Bar graph showing participant gender counts by recruitment source
- **age_boxplot.png**: Box and whisker plot showing participant age distribution by recruitment source
- **summary_table.csv**: Table of participant characteristics (age & gender) split by recruitment source 
