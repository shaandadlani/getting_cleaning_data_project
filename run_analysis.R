
##download zip file from online URL
fileurl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl,destfile="./getdata.zip")

##unzip file using unzip funciton to created unzip folder
dir.create("./unzip")
unzip("getdata.zip",exdir = "unzip")


##read in needed files as tables

actlab<-tbl_df(read.table("./unzip/UCI HAR Dataset/activity_labels.txt"))
featurelabels<-tbl_df(read.table("./unzip/UCI HAR Dataset/features.txt"))
trainx<-tbl_df(read.table("./unzip/UCI HAR Dataset/train/X_train.txt"))
trainy<-tbl_df(read.table("./unzip/UCI HAR Dataset/train/y_train.txt"))
trainsub<-tbl_df(read.table("./unzip/UCI HAR Dataset/train/subject_train.txt"))
testx<-tbl_df(read.table("./unzip/UCI HAR Dataset/test/X_test.txt"))
testy<-tbl_df(read.table("./unzip/UCI HAR Dataset/test/y_test.txt"))
testsub<-tbl_df(read.table("./unzip/UCI HAR Dataset/test/subject_test.txt"))


##step1 - combine test and train data sets by combining rows
##step2 - relabel column names to easy to read columns
all_activities<-tbl_df(rbind(testy,trainy))
names(all_activities)<-"ActivityID"

all_subjects<-tbl_df(rbind(testsub,trainsub))
names(all_subjects)<-"SubjectID"

all_obsvdata<-tbl_df(rbind(testx,trainx))
names(all_obsvdata)<-as.character(featurelabels$V2)
names(all_obsvdata)<-make.names(names(all_obsvdata))


##assign new column names to activity labels to be able to merge data sets and have actvity names
names(actlab)<-c("ActivityID","ActivityName")
all_activities<-tbl_df(merge(all_activities,actlab))

##combine all tables into one data set
fulldata<-cbind(all_subjects,all_activities,all_obsvdata)

##remove duplicate column names and transform using tbl_df
fulldata<-tbl_df(fulldata[,unique(names(fulldata))])


##select mean and std measurements
fulldata_meanstd<-select(fulldata,SubjectID,ActivityID,ActivityName,contains("mean"),contains("std"))

##change column names to be more descriptive
names(fulldata_meanstd)<-gsub("^t", "time", names(fulldata_meanstd))
names(fulldata_meanstd)<-gsub("^f", "frequency", names(fulldata_meanstd))
names(fulldata_meanstd)<-gsub("Acc", "Accelerometer", names(fulldata_meanstd))
names(fulldata_meanstd)<-gsub("Gyro", "Gyroscope", names(fulldata_meanstd))
names(fulldata_meanstd)<-gsub("Mag", "Magnitude", names(fulldata_meanstd))
names(fulldata_meanstd)<-gsub("BodyBody", "Body", names(fulldata_meanstd))


##take the mean of all columns, except the first 3 using the aggregate function
colsformean<-fulldata_meanstd[,3:89] 
tidydata <- aggregate(colsformean,list(fulldata_meanstd$SubjectID,fulldata_meanstd$ActivityID,fulldata_meanstd$ActivityName), mean)


##rename first 3 columns and create file
names(tidydata)[1]<-"SubjectID"
names(tidydata)[2]<-"ActivityID"
names(tidydata)[3]<-"ActivityName"

write.table(tidydata,file="./unzip/tidy_data_file")