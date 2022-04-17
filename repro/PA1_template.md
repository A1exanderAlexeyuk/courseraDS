Here I am loading libraries!

    library(tidyverse)

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──

    ## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
    ## ✓ tibble  3.1.6     ✓ dplyr   1.0.8
    ## ✓ tidyr   1.2.0     ✓ stringr 1.4.0
    ## ✓ readr   2.1.2     ✓ forcats 0.5.1

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    library(dplyr)
    library(lubridate)

    ## 
    ## Attaching package: 'lubridate'

    ## The following objects are masked from 'package:base':
    ## 
    ##     date, intersect, setdiff, union

    library(lattice)

Loading file ‘activity.csv’ as a data.frame(); column ‘dates’ are
converted from character into a date object by lubridate; NA’s are
removed; dates categorized as logical for Weekend

    data = read.table("~/Desktop/activity.csv", 
                      sep = ",",
                      header = TRUE
                      ) %>% 
            mutate(date = ymd(date)) %>% 
            na.omit() %>% 
            mutate(day.of.the.week = weekdays(date),
                   Weekend = ifelse(day.of.the.week == "Saturday" | day.of.the.week == "Sunday", "Weekend", "Weekday")
            )

Q: What is mean total number of steps taken per day?

Assignment: Calculate the total number of steps taken per day; Calculate
and report the mean and median of the total number of steps taken per
day

Solution: I pass the data.frame() processed and group the data by the
date; I then call to summarize() and pass for functions sum, mean, and
median; Then add a column to categorize as the “Original” data

    avgDataByDate = data %>%
            group_by(date) %>% 
            summarize(Total = sum(steps),
                      Average = mean(steps),
                      Median = median(steps)
            ) %>% 
            mutate(Group = "Original")

    text01 = paste("The total number of steps taken per day is stored in the table")
    text02 = paste("The average and median steps taken per day is stored in the table")
    print(text01)

    ## [1] "The total number of steps taken per day is stored in the table"

    print(text02)

    ## [1] "The average and median steps taken per day is stored in the table"

Assignment: If you do not understand the difference between a histogram
and a barplot, research the difference between them. Make a histogram of
the total number of steps taken each day

Solution: I call the summarized table of the original data and call
hist() function; I pass the Total column of the df

![](Activity_monitoring_Proj01_files/figure-markdown_strict/unnamed-chunk-1-1.png)

Question: What is the average daily activity pattern?

Assignment: Make a time series plot of the 5-minute interval (x-axis)
and the average number of steps taken, averaged across all days (y-axis)

Solution: I pass the original data and perform a grouping function by
interval; call summarize with functions calls to sum, length, min,
quantile, mean, and max; this produces a 5 point summary, but that is
really only for me; with the mean values and interval values, I pass
those into ggplot():aes(); I then layer points and lines onto the base

    test = data %>%
            group_by(interval) %>% 
            summarize(total = sum(steps),
                      "Total Reads" = length(steps),
                      Minimum = min(steps),
                      Q1 = quantile(steps, 0.25),
                      Average = mean(steps),
                      Median = median(steps),
                      Q3 = quantile(steps, 0.75),
                      Maximum = max(steps))

    x = ggplot(NULL, aes(y = test$Average, x = test$interval))
    x + geom_line() + geom_point() +
            labs(x = "Interval",
                 y = "Average steps",
                 title = "Average steps taken per interval across all data") +
            theme_classic()

![](Activity_monitoring_Proj01_files/figure-markdown_strict/unnamed-chunk-2-1.png)
Question Which 5-minute interval, on average across all the days in the
dataset, contains the maximum number of steps?

Solution: Use filter() to pull the row of the previous data.frame() that
contains the max value among the Maximum column; I then identify which
interval that value is by pulling from that colum

    intervalWithMaxSteps = test %>% filter(Average == max(test$Average))
    intervalWithMaxSteps = intervalWithMaxSteps$interval

    text = paste("The 5 minute interval with the highest average number of steps on average is", intervalWithMaxSteps)
    print(text)

    ## [1] "The 5 minute interval with the highest average number of steps on average is 835"

Question: Imputing missing values Note that there are a number of
days/intervals where there are missing values (coded as NA). The
presence of missing days may introduce bias into some calculations or
summaries of the data.

Assignment: Calculate and report the total number of missing values in
the dataset (i.e. the total number of rows with NAs)

Solution: Read raw data and pass into a filter call that identifies only
rows with NA; call dimensions on this dataframe and take only the rows
(or the first value within the vector); print that value

    rowsNA = read.table("~/Desktop/activity.csv", 
                      sep = ",",
                      header = TRUE
                      ) %>% 
            filter_all(any_vars(is.na(.)))

    numOfRowsNA = dim(rowsNA)[1]
    numOfRowsNA = paste("The total number of missing values in the dataset is", numOfRowsNA)
    print(numOfRowsNA)

    ## [1] "The total number of missing values in the dataset is 2304"

Assignment: Devise a strategy for filling in all of the missing values
in the dataset. The strategy does not need to be sophisticated. For
example, you could use the mean/median for that day, or the mean for
that 5-minute interval, etc.

Solution: Perform a for loop to ID NA values and replace with the
overall average of steps over all rows

    #fill in average value for that day 
    newData = read.table("~/Desktop/activity.csv", 
                      sep = ",",
                      header = TRUE
                      ) %>% 
            mutate(date = ymd(date))

    for (i in 1:length(newData$steps)) {
            
            if(is.na(newData$steps[i])) {
                    
                    newData$steps[i] = mean(avgDataByDate$Average)
                    
            }
            
    }

Assignment: Create a new dataset that is equal to the original dataset
but with the missing data filled in.

Solution: See previous statement and expression

Assignment: Make a histogram of the total number of steps taken each day
and Calculate and report the mean and median total number of steps taken
per day. Do these values differ from the estimates from the first part
of the assignment? What is the impact of imputing missing data on the
estimates of the total daily number of steps?

Solution:

Created a new dataframe that is grouped by date and provides sum, mean,
and median of steps; categorize data as altered; create historgram with
total steps per day; bind this ‘altered’ data with ‘Original’ data; call
a plot function to compare both using facet\_wrap();

    avgNewDataByDate = newData %>%
            na.omit() %>% 
            group_by(date) %>% 
            summarize(Total = sum(steps),
                      Average = mean(steps),
                      Median = median(steps)
            ) %>% 
            mutate(Group = "Altered")

    hist(avgNewDataByDate$Total, 
         main = "Subjects' distribution of total steps in a day",
         breaks = 20,
         col = "red",
         xlab = "Total steps",
         ylab = "Frequency", 
         )

![](Activity_monitoring_Proj01_files/figure-markdown_strict/unnamed-chunk-7-1.png)

    compare = bind_rows(avgNewDataByDate, avgDataByDate)

    x = ggplot(compare, aes(y = Average, x = date))

    x + geom_line() + 
            geom_point() + 
            facet_wrap(Group ~ ., nrow = 2, dir ="v") +
            theme_classic() +
            labs(x = "Date",
                 y = "Average steps") 

![](Activity_monitoring_Proj01_files/figure-markdown_strict/unnamed-chunk-7-2.png)

    y = ggplot(compare, aes(y = Median, x = date))

    y + geom_line() + 
            geom_point() + 
            facet_wrap(Group ~ ., nrow = 2, dir ="v") +
            theme_classic() +
            labs(x = "Date",
                 y = "Average steps") 

![](Activity_monitoring_Proj01_files/figure-markdown_strict/unnamed-chunk-7-3.png)

    text = paste("The impact of replacing values with the overall mean of steps does not impact the distribution or average significantly by eye; however, the median values on average could be changed significantly")

    print(text)

    ## [1] "The impact of replacing values with the overall mean of steps does not impact the distribution or average significantly by eye; however, the median values on average could be changed significantly"

Are there differences in activity patterns between weekdays and
weekends? For this part the weekdays() function may be of some help
here. Use the dataset with the filled-in missing values for this part.

Create a new factor variable in the dataset with two levels – “weekday”
and “weekend” indicating whether a given date is a weekday or weekend
day.

Make a panel plot containing a time series plot (i.e. type = “l”) of the
5-minute interval (x-axis) and the average number of steps taken,
averaged across all weekday days or weekend days (y-axis). See the
README file in the GitHub repository to see an example of what this plot
should look like using simulated data.

    test = data %>%
            na.omit() %>% 
            group_by(interval, Weekend) %>% 
            summarize(total = sum(steps),
                      "Total Reads" = length(steps),
                      Minimum = min(steps),
                      Q1 = quantile(steps, 0.25),
                      Average = mean(steps),
                      Median = median(steps),
                      Q3 = quantile(steps, 0.75),
                      Maximum = max(steps))

    ## `summarise()` has grouped output by 'interval'. You can override using the
    ## `.groups` argument.

    x = ggplot(test, aes(y = Average, x = interval))

    x + geom_line() + 
            geom_point() + 
            facet_wrap(Weekend ~ ., nrow = 2, dir ="v") +
            theme_classic() +
            labs(x = "Interval",
                 y = "Average steps",
                 title = "Average steps taken per interval by day of the week") 

![](Activity_monitoring_Proj01_files/figure-markdown_strict/unnamed-chunk-8-1.png)

    text = paste("Based on the graph on weekdays activity starts at earlier intervals and has a pronounced peak, where on weekends activity starts at later intervals and has probabaly a larger average value of peaks")

    print(text)

    ## [1] "Based on the graph on weekdays activity starts at earlier intervals and has a pronounced peak, where on weekends activity starts at later intervals and has probabaly a larger average value of peaks"
