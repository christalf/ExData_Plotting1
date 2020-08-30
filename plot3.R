## Exploratory Data Analysis Course - Coursera.
## Peer Assignment - Week 1.
## August 29, 2020.

##--------------------------------------------------------------------------------##
## Downloading and unzipping the data.
datadir <- "."                                  # Working directory.
datasetFile <- "dataset.zip"                    # Name of the file to be downloaded.
datasetPath <- file.path(datadir, datasetFile)  # Complete pathname of the file to be downloaded.

dataUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
download.file(dataUrl, destfile = datasetPath, method = "curl")
dateDownloaded <- date()
zipContent <- unzip(datasetPath, exdir = datadir)
zipContent

##--------------------------------------------------------------------------------##
## Reading the data.
## Rough memory estimate: (2.075.259 lines * 9 cols * 8 bytes) / 2^20 = 142.5 MB.
library(data.table)

hpcDataset <- fread(zipContent[1],    # "sep" and "header" are automatically detected.
                    na.strings = "?")

tables()                                         # 2,075,259 rows, 143 MB.
str(hpcDataset)
summary(hpcDataset)                              # all numeric variables have 25,979 NAs.

## Subsetting observations from dates 01/02/2007 and 02/02/2007.
twoDays <- hpcDataset[Date == "1/2/2007" | Date == "2/2/2007", ]

tables()                                         # 2,880 rows, < 1 MB.

## Coercing 'Date' variable from character to Date class, and 'Time' variable from
## character to POSIXct class.
twoDays[, Date := as.Date(Date, format = "%d/%m/%Y")]
twoDays[, Time := {tmp <- paste(Date, Time);
                   strptime(tmp, format = "%Y-%m-%d %H:%M:%S")}]

summary(twoDays)                                 # No NAs.

##--------------------------------------------------------------------------------##
## Constructing the required plot 3 on the screen graphic device.
with(twoDays, plot(Time, Sub_metering_1,
                   xlab = "", ylab = "Energy sub metering",
                   type = "n"))
with(twoDays, points(Time, Sub_metering_1, type = "l", col = "grey20"))
with(twoDays, points(Time, Sub_metering_2, type = "l", col = "red"))
with(twoDays, points(Time, Sub_metering_3, type = "l", col = "blue"))
legend("topright", lty = "solid", col = c("grey45", "red", "blue"),
       legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"),
       cex = 0.7)

##--------------------------------------------------------------------------------##
## Sending plot 3 to the PNG file graphic device.
dev.copy(png, file = "plot3.png", width = 480, height = 480)
dev.off()

