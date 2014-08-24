library(sqldf)

# Load Activity Labels into actlabels Variable - reads 6 rows 2 columns
actlabels<-read.table(".\\UCI HAR Dataset\\activity_labels.txt")

#Load list of features from features.txt file 561 rows - second column has name
features<-read.table(".\\UCI HAR Dataset\\features.txt")

#Isolate descriptive list of features
collist <- features$V2
#Identify column numbers with mean or std in the description
meancols <- grep("mean()",collist)
stdcols <- grep("std()",collist)

#combine the positions and sort to order column numbers 
varcols <- c( meancols, stdcols)
varcols<- sort(varcols)

#Using column numbers narrow list of column numbers - this will give us the column names
#for final data set
#Remove special characters
filtered_colnames <- gsub("-|\\()","",collist[varcols])

#Read Training Dataset Text file and filter only the list of columns 
# using column numbers identifed above using varcols variable
#Set the column names
#
xtrain<-read.table(".\\UCI HAR Dataset\\train\\X_train.txt")
filtered_xtrain <- xtrain[,varcols]
colnames(filtered_xtrain)<-filtered_colnames

#Read in Subject information and add to training data set
subjecttrain<-read.table(".\\UCI HAR Dataset\\train\\subject_train.txt")
colnames(subjecttrain)<-c("Subject")
filtered_xtrain <-cbind(filtered_xtrain,subjecttrain)

#Read in Activity for Training data set and add to to Training dataset
ytrain<-read.table(".\\UCI HAR Dataset\\train\\y_train.txt")
a<-data.frame(actlabels[ytrain$V1,2])
colnames(a)<-c("Activity")
filtered_xtrain <-cbind(filtered_xtrain,a)

#Read in test data and filter to mean or std columns only
xtest<-read.table(".\\UCI HAR Dataset\\test\\X_test.txt")
filtered_xtest <- xtest[,varcols]
colnames(filtered_xtest)<-filtered_colnames

#Read in subject information
subjecttest<-read.table(".\\UCI HAR Dataset\\test\\subject_test.txt")
colnames(subjecttest)<-c("Subject")

#Read in activity information
ytest<-read.table(".\\UCI HAR Dataset\\test\\y_test.txt")
b<-data.frame(actlabels[ytest$V1,2])
colnames(b)<-c("Activity")

#Create Final Test set
filtered_xtest<-cbind(filtered_xtest,subjecttest)
filtered_xtest<-cbind(filtered_xtest,b)

#Create the final data set by row binding filtered data sets; this is the first tidied data set
nv<-rbind(filtered_xtrain,filtered_xtest)
write.table(nv,"./step4.txt",row.names=FALSE)

# Aggregate above data by Subject and Activity; calculate mean of all
groupedOutput <- aggregate(nv[filtered_colnames],list(Subject=nv$Subject,Act=nv$Activity),mean)

DescVariables<-gsub("^t","Time Domain_",filtered_colnames)
DescVariables<-gsub("^f","FFT_",DescVariables)
DescVariables<-gsub("Acc","Acceleration_",DescVariables)
DescVariables<-gsub("std","StandardDeviation",DescVariables)
DescVariables<-gsub("mean","Mean",DescVariables)


#Wanted to try a different route using sqldf
#create a sql string with column names and group by subject and activity
mystr= " Select subject, activity "
for ( i in filtered_colnames){
  mystr <- paste(mystr, ",avg( ")
  mystr<- paste(mystr, i)
  mystr<- paste( mystr, ")")
}
for (i in 1:length(filtered_colnames)){
  write.table(filtered_colnames[i],"./CodeBook.md",append=TRUE,row.names=FALSE,col.names=FALSE)
  write.table(paste("\t",DescVariables[i]),"./CodeBook.md",append=TRUE,row.names=FALSE,col.names=FALSE)
  write.table(paste("\t",range(nv[i])),"./CodeBook.md",append=TRUE,row.names=FALSE,col.names=FALSE)
  
}

mystr<- paste(mystr,"  from nv group by subject, activity")
sqlo <-sqldf(mystr)

#Output Data from above
write.table(groupedOutput,"./tidied.txt",row.names=FALSE)

write.table(sqlo,"./sqlo.txt",row.names=FALSE)

