# Download the File from server
        fileURL<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile = "/mydata/dataCleanup/HumanActivityDataSet.zip", method = "curl")
        fileURL<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        setwd("./mydsproject/")

# extract Zip data file
        unzip("./mydata/dataCleanup/HumanActivityDataSet.zip",unzip="internal" ,exdir="./mydata/dataCleanup/HumanActivityDataSet/" )
        list.files("./mydata/dataCleanup/HumanActivityDataSet/UCI HAR Dataset",recursive=TRUE)

# read the test data from extracted folder
        subjectTest = read.table('./test/subject_test.txt',header=FALSE)
        xTest = read.table('./test/x_test.txt',header=FALSE)
        yTest = read.table('./test/y_test.txt',header=FALSE)
        
# read the training data from extracted folder
        subjectTrain = read.table('./train/subject_train.txt',header=FALSE)
        xTrain = read.table('./train/x_train.txt',header=FALSE)
        yTrain = read.table('./train/y_train.txt',header=FALSE)
        
        dsActivitLbl <- read.table("./mydata/dataCleanup/HumanActivityDataSet/UCI HAR Dataset/activity_labels.txt",header = TRUE)
        dsFeatureInfo <- read.table("./mydata/dataCleanup/HumanActivityDataSet/UCI HAR Dataset/features.txt",header = TRUE)
        subjectTrain = read.table('./train/subject_train.txt',header=FALSE)
        setwd("./mydata/dataCleanup/HumanActivityDataSet/UCI HAR Dataset")
# merge training and test Data
        ActivityDataSetX <- rbind(xTrain, xTest)
        ActivityDataSetY <- rbind(yTrain, yTest)
        ActivityDataSetSubject<-rbind(subjectTrain, subjectTest)
# check summary of dataset
#        str(ActivityDataSetX)
#        str(ActivityDataSetY)
#        str(ActivityDataSetSubject)

# Extract the mean and standard deviation columns  
ActivityDataSetMeanStd <- ActivityDataSetX[, grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2])]

# set the Names for the columns
names(ActivityDataSetMeanStd) <- read.table("features.txt")[grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2]), 2]

#View Dataset
#View(ActivityDataSetMeanStd)

# Prepare the Activity dataset
ActivityDataSetY[, 1] <- read.table("activity_labels.txt")[ActivityDataSetY[, 1], 2]
names(ActivityDataSetY) <- "Activity"
View(ActivityDataSetY)

# Prepare Subject Dataset
names(ActivityDataSetSubject) <- "Subject"
View(ActivityDataSetSubject)

# combine all data set
ActivityDataSet <- cbind(ActivityDataSetMeanStd, ActivityDataSetY, ActivityDataSetSubject)
View(ActivityDataSet)

# Appropriat labels for data set with descriptive variable names
names(ActivityDataSet) <- make.names(names(ActivityDataSet))
names(ActivityDataSet) <- gsub('Acc',"Acceleration",names(ActivityDataSet))
names(ActivityDataSet) <- gsub('GyroJerk',"AngularAcceleration",names(ActivityDataSet))
names(ActivityDataSet) <- gsub('Gyro',"AngularSpeed",names(ActivityDataSet))
names(ActivityDataSet) <- gsub('Mag',"Magnitude",names(ActivityDataSet))
names(ActivityDataSet) <- gsub('^t',"TimeDomain.",names(ActivityDataSet))
names(ActivityDataSet) <- gsub('^f',"FrequencyDomain.",names(ActivityDataSet))
names(ActivityDataSet) <- gsub('\\.mean',".Mean",names(ActivityDataSet))
names(ActivityDataSet) <- gsub('\\.std',".StandardDeviation",names(ActivityDataSet))
names(ActivityDataSet) <- gsub('Freq\\.',"Frequency.",names(ActivityDataSet))
names(ActivityDataSet) <- gsub('Freq$',"Frequency",names(ActivityDataSet))
View(ActivityDataSet)

# Aggricate the data
FinalActivityDataSet<-aggregate(. ~Subject + Activity, ActivityDataSet, mean)
FinalActivityDataSet<-FinalActivityDataSet[order(FinalActivityDataSet$Subject,FinalActivityDataSet$Activity),]

# Final tidy Data set and Export File
View(FinalActivityDataSet)

#2nd tidy data set with the average of each variable for each activity and each subject
FinalActivityDataSetAverage <- ddply(FinalActivityDataSet, .(Subject, Activity), .fun=function(x){ colMeans(x[,-c(1:2)]) })
View(FinalActivityDataSetAverage)

# Export Final dataset to file
write.table(FinalActivityDataSet, "FinalActivityDataSet.txt", sep="\t" , row.names = FALSE)
write.table(FinalActivityDataSetAverage, "FinalActivityDataSetAverage.txt", sep="\t" , row.names = FALSE)

