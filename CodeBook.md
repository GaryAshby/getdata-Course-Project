#Install Libraries used in the package.
```R
library(dplyr)
```

#check if the data exists, if not download.
```R
if (!file.exists("getdata-projectfiles-UCI HAR Dataset.zip"))
    {
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile = "getdata-projectfiles-UCI HAR Dataset.zip")
        unzip("getdata-projectfiles-UCI HAR Dataset.zip", exdir = ".")
    }
```
#Load Features (variable names)
```R
feature <- read.table("./UCI HAR Dataset/features.txt")
names(feature) <- c("featureid","feature")
feature_filtered <- filter(feature, grepl("std|mean", as.character(feature$feature), ignore.case = TRUE))
feature_filtered <- filter(feature_filtered, !grepl("angle", as.character(feature_filtered$feature), ignore.case = TRUE))
```
#Load Activity Labels
```R
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels <- rename(activity_labels, label = V1, label_description = V2)
```

#Load Training Data
```R
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_set <- read.table("UCI HAR Dataset/train/x_train.txt")
train_labels <- read.table("UCI HAR Dataset/train/y_train.txt")
train_subset <- select(train_set, feature_filtered$featureid)
names(train_subset) <- feature_filtered$feature
```

#Load Test Data
```R
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_set <- read.table("UCI HAR Dataset/test/x_test.txt")
test_labels <- read.table("UCI HAR Dataset/test/y_test.txt")
test_subset <- select(test_set, feature_filtered$featureid)
names(test_subset) <- feature_filtered$feature
```

#Combine extra variables
```R
test_data <- mutate(test_subset, label = as.integer(test_labels$V1))
test_data <- mutate(test_data, subject = as.integer(test_subject$V1))
train_data <- mutate(train_subset, label = as.integer(train_labels$V1))
train_data <- mutate(train_data, subject = as.integer(train_subject$V1))
```

#Combined all the data.
```R
complete_data <- rbind(train_data, test_data)
complete_data <- merge(complete_data, activity_labels)
```

#Create Tidy Dataset
```R
complete_data_grouped <- group_by(complete_data, label_description, subject)
complete_data_grouped_summarised <- summarise_each(complete_data_grouped, funs(mean))
write.table(complete_data_grouped_summarised, "CompleteTidyData.txt", row.names = FALSE)
```
