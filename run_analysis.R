#run_analysis.R
#1) You should create one R script called run_analysis.R that does the following. 
#2) Merges the training and the test sets to create one data set.
#3) Extracts only the measurements on the mean and standard deviation for each measurement. 
#4) Uses descriptive activity names to name the activities in the data set
#5) Appropriately labels the data set with descriptive variable names. 
#6) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#SetWD("C:\Gary\RData\GETDATA-032")

#2) Merges the training and the test sets to create one data set.
#3) Extracts only the measurements on the mean and standard deviation for each measurement. 

library(dplyr)

if (!file.exists("getdata-projectfiles-UCI HAR Dataset.zip"))
    {
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile = "getdata-projectfiles-UCI HAR Dataset.zip")
        unzip("getdata-projectfiles-UCI HAR Dataset.zip", exdir = ".")
    }

#Load Features (variable names)
feature <- read.table("./UCI HAR Dataset/features.txt")
names(feature) <- c("featureid","feature")
feature_filtered <- filter(feature, grepl("std|mean", as.character(feature$feature), ignore.case = TRUE))
feature_filtered <- filter(feature_filtered, !grepl("angle", as.character(feature_filtered$feature), ignore.case = TRUE))

#Load Activity Labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels <- rename(activity_labels, label = V1, label_description = V2)

#Load Training Data
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_set <- read.table("UCI HAR Dataset/train/x_train.txt")
train_labels <- read.table("UCI HAR Dataset/train/y_train.txt")
train_subset <- select(train_set, feature_filtered$featureid)
names(train_subset) <- feature_filtered$feature

#Load Test Data
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_set <- read.table("UCI HAR Dataset/test/x_test.txt")
test_labels <- read.table("UCI HAR Dataset/test/y_test.txt")
test_subset <- select(test_set, feature_filtered$featureid)
names(test_subset) <- feature_filtered$feature

#combine extra variables
test_data <- mutate(test_subset, label = as.integer(test_labels$V1))
test_data <- mutate(test_data, subject = as.integer(test_subject$V1))
train_data <- mutate(train_subset, label = as.integer(train_labels$V1))
train_data <- mutate(train_data, subject = as.integer(train_subject$V1))

#Combined all the data.
complete_data <- rbind(train_data, test_data)
complete_data <- merge(complete_data, activity_labels)

#6) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
complete_data_grouped <- group_by(complete_data, label_description, subject)
complete_data_grouped_summarised <- summarise_each(complete_data_grouped, funs(mean))
write.table(complete_data_grouped_summarised, "CompleteTidyData.txt", row.names = FALSE)





