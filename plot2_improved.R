## Exploratory Data Analysis Course - Coursera.
## Peer Assignment - Week 1.
## August 30, 2020.


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
## See Note1 below.
##--------------------------------------------------------------------------------##
## Reading the data
## Rough memory estimate: (2.075.259 lines * 9 cols * 8 bytes) / 2^20 = 142.5 MB.
library(data.table)

hpcDataset <- fread(zipContent[1],    # "sep" and "header" are automatically detected.
                    na.strings = "?")

tables()                                    # 2,075,259 rows, 143 MB.
str(hpcDataset)
summary(hpcDataset)                         # all numeric variables have 25,979 NAs.


##--------------------------------------------------------------------------------##
## See Note2 below.
##--------------------------------------------------------------------------------##
## Subsetting observations from dates 01/02/2007 and 02/02/2007.
twoDays <- hpcDataset[Date %in% c("1/2/2007", "2/2/2007")]

tables()                                    # 2,880 rows, < 1 MB.


##--------------------------------------------------------------------------------##
## See Note3 below.
##--------------------------------------------------------------------------------##
## Coercing 'Time' variable from character to POSIXct class (we could've created a
## new variable, say 'DateTime', by just naming it before operator ':=').
twoDays[, Time := {tmp <- paste(Date, Time);
                   as.POSIXct(tmp, format = "%d/%m/%Y %H:%M:%S")}]

summary(twoDays)                            # No NAs.


##--------------------------------------------------------------------------------##
## Constructing the required plot 2 on the screen graphic device.
## - Notice: instead of the two first arguments below, we can also use the formula
##           'Global_active_power ~ Time'.
with(twoDays, plot(Time, Global_active_power,
                   xlab = "", ylab = "Global Active Power (kilowatts)",
                   type = "l"))

##--------------------------------------------------------------------------------##
## Sending plot 2 to the PNG file graphic device.
dev.copy(png, file = "plot2.png", width = 480, height = 480)
dev.off()



##-------##
## Note1 ##
##-------##

## Es realmente impresionante la diferencia que hay entre la función "fread()" del
## paquete "data.table" y la función "read.table()" del paquete "utils" de R:
##   - No solamente en cuanto a la velocidad de lectura (que ahora vamos medir, para
##     verificar lo que ya vimos en el Módulo 1 del curso "Getting and Cleaning
##     Data"; ver al final "SessionInfo" para tener en cuenta los parámetros del hw
##     y sw utilizado).
##   - Sino también en cuanto a la mayor eficiencia de escritura de código, en
##     términos de claridad y concisión.

## Leyendo con fread().
system.time(fread(zipContent[1],
                  na.strings = "?"))       ## Lee los 143 MB en menos de 1 segundo.

## Leyendo con read.table().
system.time(read.table(zipContent[1],
                       sep = ";",
                       header = TRUE,
                       na.strings = "?"))  ## Lee los 145 MB en aprox. 6 seg.!!!!

## Leyendo con read.table(), tratando de acelerar diciéndole a R las clases de
## las columnas (ya tenemos los datos en "hpcDataset" y podemos usarlo para
## extraer las clases de las variables, pero normalmente lo que habría que
## hacer, según ya lo vimos en el Módulo 1 del "R Programming", es leer con
## read.table() las primeras 100 o 500 líneas de datos, extraer de ahí las clases
## y volver a usar read.table() para leer completamente los datos).
classes <- sapply(hpcDataset, class)  
system.time(read.table(zipContent[1],
                       sep = ";",
                       header = TRUE,
                       na.strings = "?",
                       colClasses = classes))  ## Ahora tarda 4 seg. aprox.


##-------##
## Note2 ##
##-------##

## Alternativas de subsetting dentro del mismo paquete "data.table":
## 1.
twoDays <- hpcDataset[Date == "1/2/2007" | Date == "2/2/2007", ]
## 2. 
## Podemos sacar la coma ("data.table" en ese caso selecciona líneas, no
## columnas como "data.frame").
twoDays1 <- hpcDataset[Date == "1/2/2007" | Date == "2/2/2007"]
identical(twoDays, twoDays1)
## 3.
## Podemos también usar, por ejemplo, el operador %in%.
twoDays2 <- hpcDataset[Date %in% c("1/2/2007", "2/2/2007")]
identical(twoDays, twoDays2)
## 4.
## Podemos usar también el comando "which()".
twoDays3 <- hpcDataset[which(Date == "1/2/2007" | Date == "2/2/2007")]
identical(twoDays, twoDays3)
## 5.
## El paquete "data.table" también tiene una función "subset()".
twoDays3.5 <- subset(hpcDataset, Date %in% c("1/2/2007", "2/2/2007"))
identical(twoDays, twoDays3.5)

## Alternativas de subsetting si no hubiesemos usado el paquete "data.table".
## 1.
twoDays4 <- hpcDataset[hpcDataset$Date == "1/2/2007" | hpcDataset$Date == "2/2/2007", ]
identical(twoDays, twoDays4)
## 2.
twoDays5 <- hpcDataset[hpcDataset$Date %in% c("1/2/2007", "2/2/2007"), ]
identical(twoDays, twoDays5)
## 3.
twoDays6 <- hpcDataset[which(hpcDataset$Date == "1/2/2007" |
                             hpcDataset$Date == "2/2/2007"), ]
identical(twoDays, twoDays6)
## 4. Y todas las demás opciones que hay con:
##    - la función subset() del paquete "base".
##    - la función filter() del paquete "dplyr".
##    - etc.


##-------##
## Note3 ##
##-------##

## En el script original, había puesto el siguiente comentario y código:

## Coercing 'Date' variable from character to Date class, and 'Time' variable from
## character to POSIXct class.
twoDays[, Date := as.Date(Date, format = "%d/%m/%Y")]
twoDays[, Time := {tmp <- paste(Date, Time);
strptime(tmp, format = "%Y-%m-%d %H:%M:%S")}]

## Aquí hay que hacer DOS AUTO-CRÍTICAS:

## - Primero, no hacía falta convertir la variable "Date" por separado. El
##   objetivo era tener una variable completa Date/Time, lo cual se puede
##   obtener modificando directa y solamente la variable "Time".

## - Segundo, la aplicación de "strptime()" a paste(Date, Time) que se
##   hace ahí, origina el siguiente WARNING:
##   "In strptime(tmp, format = "%Y-%m-%d %H:%M:%S") :
##         strptime() usage detected and wrapped with as.POSIXct().
##         This is to minimize the chance of assigning POSIXlt columns, which
##         use 40+ bytes to store one date (versus 8 for POSIXct).
##         Use as.POSIXct() (which will call strptime() as needed internally)
##         to avoid this warning".
##   Es decir, el mismo mensaje nos está diciendo que conviene en este caso
##   usar as.POSIXct().


##--------------##
## Session Info ##
##--------------##
sessionInfo()
# R version 3.6.3 (2020-02-29)
# Platform: x86_64-pc-linux-gnu (64-bit)
# Running under: Ubuntu 18.04.5 LTS
# 
# Matrix products: default
# BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.7.1
# LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.7.1
# 
# Random number generation:
#         RNG:     Mersenne-Twister 
# Normal:  Inversion 
# Sample:  Rounding 
# 
# locale:
#         [1] LC_CTYPE=es_AR.UTF-8       LC_NUMERIC=C               LC_TIME=es_AR.UTF-8       
# [4] LC_COLLATE=es_AR.UTF-8     LC_MONETARY=es_AR.UTF-8    LC_MESSAGES=es_AR.UTF-8   
# [7] LC_PAPER=es_AR.UTF-8       LC_NAME=C                  LC_ADDRESS=C              
# [10] LC_TELEPHONE=C             LC_MEASUREMENT=es_AR.UTF-8 LC_IDENTIFICATION=C       
# 
# attached base packages:
#         [1] stats     graphics  grDevices utils     datasets  methods   base     
# 
# other attached packages:
#         [1] data.table_1.13.0
# 
# loaded via a namespace (and not attached):
#         [1] compiler_3.6.3 tools_3.6.3






