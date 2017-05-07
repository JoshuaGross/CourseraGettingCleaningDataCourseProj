# plyr: https://cran.r-project.org/web/packages/plyr/index.html
library(plyr)

filename <- "dataset.zip"
url      <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

## Download dataset if it doesn't already exist
if (!file.exists(filename)) {
  download.file(url, filename, method="curl")
}
# If UCI Har Dataset directory isn't on disk, unzip dataset
if (!file.exists("UCI HAR Dataset")) {
  unzip(filename)
}

# Step 1
# Load activity labels and features
# Convert labels to characters so that data can be easily grepped
activityLabels     <- read.table("UCI Har Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features           <- read.table("UCI HAR Dataset/features.txt")
features[,2]       <- as.character(features[,2])

# Step 2
# Pull out mean and stddev features, and correct column names
meanStddevFeatures       <- grep(".*(mean|std).*", features[,2])
meanStddevFeatures.names <- features[meanStddevFeatures,2]
meanStddevFeatures.names <- gsub('[()]', '', meanStddevFeatures.names)

# Step 3
# Load training and test data
x_train       <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train       <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
x_test        <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test        <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test  <- read.table("UCI HAR Dataset/test/subject_test.txt")

# Step 4 - create x/y/subject dataframes combining test and training data
x_joined       <- rbind(x_test,       x_train)
y_joined       <- rbind(y_test,       y_train)
subject_joined <- rbind(subject_test, subject_train)

# Step 5 - subset joined data with only the columns we're interested in
x_joined        <- x_joined[, meanStddevFeatures]
names(x_joined) <- meanStddevFeatures.names

# Step 6 - Relabel y data
y_joined[, 1]   <- activityLabels[y_joined[, 1], 2]
names(y_joined) <- "activity"

# Step 7 - relabel subjects
names(subject_joined) <- "subject"

# Step 7 - join all data into single dataframe
joined_df <- cbind(x_joined, y_joined, subject_joined)
write.table(joined_df, "joined_untidy.txt", row.names=T, quote=F)

# Step 8 - new "tidy" dataset. Get mean of each variable per-activity and per-subject.
tidy <- ddply(joined_df, .(subject, activity), function (x) colMeans(x[, 1:66]))
write.table(tidy, "tidy.txt", row.names=T, quote=F)
