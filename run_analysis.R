##Getting and Cleaning Data - Week 4 Project
##Geoff Hebertson

##Last edited: 8/4/2019

getwd()
setwd("./Getting and Cleaning Data/Week 4")
dir.create("./Week 4 Project")
setwd("./Week 4 Project")

library(dplyr)

# Check if archive already exists
filename <- "Getting and Cleaning Data Week 4.zip"
if(!file.exists(filename)){
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, filename, methord = "curl")
}

#Checking if folder exists
if (!file.exists("UCI HAR Dataset")) {
    unzip(filename)
}

#Assinging all data frames
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n", "functions"))
activites <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")


#Merge the training and test sets to create one data set
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
Subject <- rbind(subject_train, subject_test)
Merged_Data <- cbind(Subject, Y, X)

#Extract only the measurment on the mean and standard deviation for each measurement
TidyData <- Merged_Data %>%
    select(subject, code, contains("mean"), contains("std"))

#Uses descriptive activity names to name the activites in the data set
TidyData$code <- activites[TidyData$code, 2]

#Appropriately labels the data set with descriptive variable names
names(TidyData)[2] = "activity"
names(TidyData) <- gsub("Acc", "Accelerometer", names(TidyData))
names(TidyData) <- gsub("Gyro", "Gyroscope", names(TidyData))
names(TidyData) <- gsub("BodyBody", "Body", names(TidyData))
names(TidyData) <- gsub("Mag", "Magnitude", names(TidyData))
names(TidyData) <- gsub("^t", "Time", names(TidyData))
names(TidyData) <- gsub("^f", "Frequency", names(TidyData))
names(TidyData) <- gsub("tBody", "TimeBody", names(TidyData))
names(TidyData) <- gsub("-mean()", "Mean", names(TidyData), ignore.case = TRUE)
names(TidyData) <- gsub("-std()", "STD", names(TidyData), ignore.case = TRUE)
names(TidyData) <- gsub("-freq()", "Frequency", names(TidyData), ignore.case = TRUE)
names(TidyData) <- gsub("angle", "Angle", names(TidyData))
names(TidyData) <- gsub("gravity", "Gravity", names(TidyData))

#From the data in step 4, create a second, independent tidy set with the average of each variable for each activity and each subject
FinalData <- TidyData %>%
    group_by(subject, activity) %>%
    dplyr::summarise_all(funs(mean))
write.table(FinalData, "FinalData.txt", row.names = FALSE)

str(FinalData)
View(FinalData)

#Create codebook
library(knitr)
knit2html("codebook.Rmd")
