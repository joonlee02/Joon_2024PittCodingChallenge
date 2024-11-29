install.packages("dplyr")      
install.packages("tidyverse")  
install.packages("ggplot2")    
library(dplyr)
library(tidyverse)
library(ggplot2)

# Load the data 
load("CodeChallenge2024.RData") 

### Question 1 - Data Cleaning ###

# Rename ID columns for clarity
colnames(HAM_protect)[colnames(HAM_protect) == "ID"] <- "old_id"
colnames(HAM_sleep)[colnames(HAM_sleep) == "ID"] <- "new_id"

# Define a list of relevant participant IDs
relevant_ids <- c(
  215622, 219954, 202278, 203264, 210626, 215088, 216028, 216845, 217173, 217909,
  219089, 219809, 220330, 220363, 220909, 431209, 431224, 203521, 208427, 210701,
  211101, 216235, 216467, 218219, 218457, 220531, 220566, 221181, 221193, 221206,
  221262, 222067, 431230, 207224, 207989, 209662, 217630, 219658, 220186, 220477,
  220492, 220597, 220796, 220865, 221018, 221036, 221228, 221242, 221569, 114567,
  202735, 206983, 209462, 212857, 214902, 217008, 217719, 220513, 220523, 220678,
  220789, 220947, 221256, 221295, 221301, 221423, 221715, 222093, 440181, 440207,
  440214, 440215, 440216, 440350, 440592, 115300, 210381, 210387, 213167, 213708,
  215211, 219772, 219956, 220024, 220758, 221298, 221674, 221916, 222091, 440042
)

# Filter id_map to include only relevant IDs
id_map <- id_map %>% filter(old_id %in% relevant_ids)

# Map old IDs to new IDs for HAM_protect and HAM_sleep datasets
HAM_protect <- merge(HAM_protect, id_map, by = "old_id", all.x = TRUE)
HAM_sleep <- merge(HAM_sleep, id_map, by = "new_id", all.x = TRUE)

# Filter HAM_protect and HAM_sleep datasets to include only relevant participants
HAM_protect <- HAM_protect %>% filter(old_id %in% relevant_ids)
HAM_sleep <- HAM_sleep %>% filter(old_id %in% relevant_ids)

# Define relevant HAM columns, excluding unwanted columns (ham_3a_wl to ham_3e_pdw)
relevant_cols <- grep("^ham_", names(HAM_protect), value = TRUE)
exclude_cols <- c("ham_3a_wl", "ham_3b_wd", "ham_3c_rld", "ham_3d_asa", "ham_3e_pdw")
relevant_cols <- setdiff(relevant_cols, exclude_cols)

# Function to clean and calculate HAM scores
clean_HAM <- function(data) {
  # Convert relevant columns to numeric, treating "NA" as missing
  data[relevant_cols] <- lapply(data[relevant_cols], function(x) {
    x <- as.character(x)
    x[x == "NA"] <- NA
    as.numeric(x)
  })
  
  # Remove rows where all relevant HAM columns are NA
  data <- data %>% filter(rowSums(!is.na(select(., all_of(relevant_cols)))) > 0)
  
  # Calculate HAM score as the sum of relevant columns
  data <- data %>%
    rowwise() %>%
    mutate(HAM_score = sum(c_across(all_of(relevant_cols)), na.rm = TRUE)) %>%
    ungroup()
  
  return(data)
}

# Clean HAM_protect and HAM_sleep datasets
HAM_protect <- clean_HAM(HAM_protect)
HAM_sleep <- clean_HAM(HAM_sleep)

# Combine HAM_protect and HAM_sleep datasets into one
HAM_combined <- bind_rows(
  HAM_protect %>% select(new_id, HAM_score, bq_date, fug_date),
  HAM_sleep %>% select(new_id, HAM_score, bq_date, fug_date)
) %>%
  mutate(visit_date = coalesce(as.Date(bq_date, format = "%Y-%m-%d"),
                               as.Date(fug_date, format = "%Y-%m-%d"))) %>%
  filter(!is.na(visit_date))  # Remove rows without valid visit dates

# Calculate mean and latest HAM scores for each participant
mean_and_latest <- HAM_combined %>%
  group_by(new_id) %>%
  summarise(
    mean_HAM_score = mean(HAM_score, na.rm = TRUE),
    latest_HAM_score = HAM_score[which.max(visit_date)],
    latest_visit_date = max(visit_date),
    .groups = "drop"
  )

# Process consent_date data to find the first consent date for each participant
colnames(consent_date)[colnames(consent_date) == "ID"] <- "new_id"
first_consent_date <- consent_date %>%
  pivot_longer(
    cols = starts_with("reg_condate"),
    names_to = "consent_type",
    values_to = "first_consent_date"
  ) %>%
  filter(!is.na(first_consent_date)) %>%
  mutate(first_consent_date = as.Date(first_consent_date, format = "%Y-%m-%d")) %>%
  group_by(new_id) %>%
  summarise(first_consent_date = min(first_consent_date), .groups = "drop")

# Merge consent dates and find HAM scores closest to the target date
HAM_combined <- HAM_combined %>%
  left_join(first_consent_date, by = "new_id") %>%
  mutate(
    target_date = first_consent_date + 365,  # 1 year after consent
    time_diff = abs(as.numeric(difftime(visit_date, target_date, units = "days")))  # Days from target
  )

closest_HAM <- HAM_combined %>%
  group_by(new_id) %>%
  slice_min(time_diff, with_ties = FALSE) %>%
  select(new_id, HAM_score_closest = HAM_score, closest_visit_date = visit_date)

# Create the final data frame
final_df <- mean_and_latest %>%
  left_join(closest_HAM, by = "new_id") %>%
  arrange(new_id)

# Save the final data frame to a CSV file
write.csv(final_df, "final_df.csv", row.names = FALSE)

### Question 2 - Data Visualization ###

# Calculate minimum age for binning
min_age <- min(recruitment_data$Age, na.rm = TRUE)
appropriate_min <- floor(min_age / 5) * 5  # Round down to the nearest multiple of 5
interval <- 5

# Total Participants by Recruitment Source (Bar Chart)
total_participants_chart <- ggplot(recruitment_data, aes(x = RecruitSource)) +
  geom_bar(fill = "steelblue") +
  theme_minimal() +
  labs(
    title = "Total Participants by Recruitment Source",
    x = "Recruitment Source",
    y = "Number of Participants"
  ) +
  scale_y_continuous(
    breaks = seq(0, max(table(recruitment_data$RecruitSource)), by = 1),
    expand = c(0, 0)  # Ensures bars touch the x-axis
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Gender Distribution by Recruitment Source (Grouped Bar Chart)
gender_chart <- ggplot(recruitment_data, aes(x = RecruitSource, fill = Gender)) +
  geom_bar(position = "dodge") +
  theme_minimal() +
  labs(
    title = "Gender of Participants by Recruitment Source",
    x = "Recruitment Source",
    y = "Number of Participants",
    fill = "Gender"
  ) +
  scale_y_continuous(
    breaks = seq(0, max(table(recruitment_data$RecruitSource, recruitment_data$Gender)), by = 1),
    expand = c(0, 0)  # Ensures bars touch the x-axis
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Grouped Bar Chart: Participants by Group and Recruitment Source
group_recruitment_chart <- ggplot(recruitment_data, aes(x = RecruitSource, fill = Group)) +
  geom_bar(position = "dodge") +
  theme_minimal() +
  labs(
    title = "Participants by Group and Recruitment Source",
    x = "Recruitment Source",
    y = "Number of Participants",
    fill = "Group"
  ) +
  scale_y_continuous(
    breaks = seq(0, max(table(recruitment_data$RecruitSource, recruitment_data$Group)), by = 1),
    expand = c(0, 0)  # Ensures bars touch the x-axis
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Age Distribution by Recruitment Source (Boxplot)
age_boxplot <- ggplot(recruitment_data, aes(x = RecruitSource, y = Age)) +
  geom_boxplot(fill = "lightblue") +
  theme_minimal() +
  labs(
    title = "Age Distribution by Recruitment Source",
    x = "Recruitment Source",
    y = "Age"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Calculate total participants for percentage calculation
total_participants <- nrow(recruitment_data)

# Summary Table: Participants, Age, and Gender Distribution
summary_table <- recruitment_data %>%
  group_by(RecruitSource) %>%
  summarise(
    Total_Participants = n(),
    Percent_of_Total = (Total_Participants / total_participants) * 100,  # Percentage of participants per source
    Median_Age = median(Age, na.rm = TRUE),
    Min_Age = min(Age, na.rm = TRUE),
    Max_Age = max(Age, na.rm = TRUE),
    Age_IQR = IQR(Age, na.rm = TRUE),
    Female_Count = sum(Gender == "F", na.rm = TRUE),
    Male_Count = sum(Gender == "M", na.rm = TRUE),
    Percent_Female = (Female_Count / Total_Participants) * 100
  )

# Save summary table to a CSV file
write.csv(summary_table, "summary_table.csv", row.names = FALSE)

# Save charts
ggsave("total_participants_chart.png", plot = total_participants_chart, width = 8, height = 6, dpi = 300)
ggsave("gender_chart.png", plot = gender_chart, width = 8, height = 6, dpi = 300)
ggsave("age_boxplot.png", plot = age_boxplot, width = 8, height = 6, dpi = 300)
ggsave("group_recruitment_chart.png", plot = group_recruitment_chart, width = 8, height = 6, dpi = 300)
