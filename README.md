# Joon Lee 2024 Pitt Coding Challenge
This repository contains the background information, data, and R code necessary to calculate the HAM depression scale scores of the participants in the Longitudinal Research Program in Late-Life Suicide studies and visualize the participant characteristics from various recruitment sources. 

The R code achieves the following things:
- converts all old IDs of participants into new IDs and only keeps the new IDs
- calculates the HAM score of each participant from each visit (if applicable)
- calculates the mean HAM score of each participant
- calculates the visit date closest to 1 year after a participant's first consent date and identifies his/her HAM score from that date
- creates graphs & tables depicting the number of participants from each recruitment source as well as the age, gender, and group distribution of participants from each recruitment source

## Requirements
- "CodingChallenge2024.pdf": PDF of the assignment description 
- R with `dplyr`, `tidyverse`, and `ggplot2` libraries
- `CodeChallenge2024.RData`: Data file  containing data necessary for assignment
- "IDs.txt": A text file containing a list of relevant participant IDs. Note that these are "old ids".
- `JoonLee2024PittCodingAssignment.R`: R code which achieves the assignment requirements

## Steps
1. Read and understand assignment details from "CodingChallenge2024.pdf".
2. Download `CodeChallenge2024.RData`, "IDs.txt", and `JoonLee2024PittCodingAssignment.R`.
3. Run `JoonLee2024PittCodingAssignment.R` in RStudio.
4. Outputs will be saved in the working directory as designated by the user. 

## Output Files
- **final_df.csv**: Cleaned data frame containing participant HAM scores. "latest_HAM_score" indicates a participant's HAM score from their most recent visit as indicated under "latest_visit date". "HAM_score_closest" indicates a participant's HAM score from the visit date closest to 1 year after their first consent date as indicated under "closest_visit_date".
- **total_participants_chart.png**: Bar graph showing participant counts by recruitment source
- **gender_chart.png**: Bar graph showing participant gender breakdown by recruitment source
- **age_boxplot.png**: Box and whisker plot showing participant age distribution by recruitment source
- **group_recruitment_chart.png**: Bar graph showing participant group breakdown by recruitment source
- **summary_table.csv**: Table of participant characteristics (age & gender) split by recruitment source 
