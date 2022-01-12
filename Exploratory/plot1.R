library("data.table")
#Reads in data from file then subsets data for specified dates
df <- data.table::fread(input = "household_power_consumption.txt"
                             , na.strings="?"
                             )

# Prevents histogram from printing in scientific notation
df[, Global_active_power := lapply(.SD, as.numeric), .SDcols = c("Global_active_power")]

# Change Date Column to Date Type
df[, Date := sapply(.SD, as.Date, "%d/%m/%Y"), .SDcols = c("Date")]

# Filter Dates for 2007-02-01 and 2007-02-02
df <- df[(Date >= "2007-02-01") & (Date <= "2007-02-02")]

png("plot1.png",  height=480, width=480)

## Plot 1
hist(df[, Global_active_power],
     main="Global Active Power",
     xlab="Global Active Power (kilowatts)",
     ylab="Frequency", col="Red")

dev.off()
