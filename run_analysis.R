library(data.table)
library(reshape2)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataUCI.zip"))
unzip(zipfile = "dataUCI.zip")


labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "namesVar"))
targetFeatures <- grep("(mean|std)\\(\\)", features[, namesVar])
values <- features[targetFeatures, namesVar]
values <- gsub('[()]', '', values)


train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, targetFeatures, with = FALSE]
data.table::setnames(train, colnames(train), values)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                       , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)


test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, targetFeatures, with = FALSE]
data.table::setnames(test, colnames(test), values)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)


combined <- rbind(train, test)


combined[["Activity"]] <- factor(combined[, Activity]
                              , levels = labels[["classLabels"]]
                              , labels = labels[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
