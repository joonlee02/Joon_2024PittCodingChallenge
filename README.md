# Joon_2024PittCodingChallenge
This repository contains the background information, data, and R code necessary to calculate HAM depression scale scores of the participants in the Longitudinal Research Program in Late-Life Suicide studies as well as visualize the participant characteristics from various recruitment sources. The R code achieves the following things:
- converts all old ids of participants into new ids
- calculates the HAM score of each participant at each visit point
- calculates the mean HAM score of each participant
- calculates the visit date closest to 1 year after a participant's first consent date and identifies his/her HAM score from that date (if applicable)
- creates graphs depicting the number of participants from each recruitment source as well as the age, gender, and group distribution of participants from each recruitment source

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
