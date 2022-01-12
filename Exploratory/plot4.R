library("data.table")
df <- data.table::fread(input = "household_power_consumption.txt"
                             , na.strings="?"
)
df[, Global_active_power := lapply(.SD, as.numeric), .SDcols = c("Global_active_power")]
df[, dateTime := as.POSIXct(paste(Date, Time), format = "%d/%m/%Y %H:%M:%S")]
df <- df[(dateTime >= "2007-02-01") & (dateTime < "2007-02-03")]
png("plot4.png", height=480, width=480)
par(mfrow=c(2,2))
plot(df[, dateTime], df[, Global_active_power], type="l", xlab="", ylab="Global Active Power")
plot(df[, dateTime],df[, Voltage], type="l", xlab="datetime", ylab="Voltage")
plot(df[, dateTime], df[, Sub_metering_1], type="l", xlab="", ylab="Energy sub metering")
lines(df[, dateTime], df[, Sub_metering_2], col="red")
lines(df[, dateTime], df[, Sub_metering_3],col="blue")
legend("topright", col=c("black","red","blue")
       , c("Sub_metering_1  ","Sub_metering_2  ", "Sub_metering_3  ")
       , lty=c(1,1)
       , bty="n"
       , cex=.5)
plot(df[, dateTime], df[,Global_reactive_power], type="l", xlab="datetime", ylab="Global_reactive_power")

dev.off()



