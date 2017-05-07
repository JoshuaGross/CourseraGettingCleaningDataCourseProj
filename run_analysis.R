filename <- "dataset.zip"
url      <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

## Download dataset if it doesn't already exist
if (!file.exists(filename)){
  download.file(url, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

