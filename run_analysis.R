## use the reshape2 library

library(reshape2)

filename <- "get_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load the labels and features for the activities
activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activitylabels[,2] <- as.character(activitylabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuressubset <- grep(".*mean.*|.*std.*", features[,2])
featuressubset.names <- features[featuressubset,2]
featuressubset.names = gsub('-mean', 'Mean', featuressubset.names)
featuressubset.names = gsub('-std', 'Std', featuressubset.names)
featuressubset.names <- gsub('[-()]', '', featuressubset.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuressubset]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuressubset]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
combinedData <- rbind(train, test)
colnames(combinedData) <- c("subject", "activity", featuressubset.names)

# turn activities & subjects into factors
combinedData$activity <- factor(combinedData$activity, levels = activitylabels[,1], labels = activitylabels[,2])
combinedData$subject <- as.factor(combinedData$subject)

combinedData.melted <- melt(combinedData, id = c("subject", "activity"))
combinedData.mean <- dcast(combinedData.melted, subject + activity ~ variable, mean)

write.table(combinedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
