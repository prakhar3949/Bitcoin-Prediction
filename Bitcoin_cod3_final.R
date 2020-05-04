

coin <- read.csv("coinbaseUSD_1-min_data_2014-12-01_to_2019-01-09.csv")


str(coin)

summary(coin)

plot.ts(coin$Weighted_Price, main = 'Weighted_Price Plot with Time', xy.labels = c("TIme","Weighted_Price"))

library(fpp2)

autoplot(uschange[,1:2], facets=TRUE) +
  xlab("Year") + ylab("") +
  ggtitle("Quarterly changes in US consumption and personal income")

coin_clean <- na.omit(coin)

coin$date <- as.Date(as.POSIXct(coin$Timestamp, origin="1970-01-01"))

library(lubridate)
library(dplyr)
coin_clean$date <- as.Date(as.POSIXct(coin_clean$Timestamp, origin="1970-01-01"))

coin$year <- year(coin$date)

median_price_NAs <- coin %>%
  select(year, Weighted_Price) %>%
  group_by(year) %>%
  summarise_each(funs(sum(is.nan(.))))

year_month_count <- coin %>%
  group_by(year) %>%
  tally(name = 'count')

price_with_time <- merge(median_price_NAs, year_month_count)

price_with_time$percent_NAs <-
  round(price_with_time$Weighted_Price / price_with_time$count, 2)

# visualising percentage NAs by year
ggplot(data = price_with_time, aes(x = year, y = percent_NAs)) +
  geom_bar(stat = "identity", width = 0.3)

coin_daily_price <- coin_clean %>% select(date, Weighted_Price) %>% group_by(date) %>% summarise(mean_price = mean(Weighted_Price))

plot.ts(coin_daily_price$mean_price)

coin_sub <- subset(coin_daily_price, date > "2016-12-31")

plot.ts(coin_sub$mean_price)

library(forecast)

ts_train <- ts(coin_sub$mean_price, frequency = 365, start = c(2017,1))
plot(ts_train)

coin_decomp <- decompose(ts_train)
plot(coin_decomp)

#i check stationarity using dicky fuller
list_packages <- c("forecast", "readxl", "stargazer", "fpp", 
                   "fpp2", "scales", "quantmod", "urca",
                   "vars", "tseries", "ggplot2", "dplyr")
new_packages <- list_packages[!(list_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Load necessary packages
lapply(list_packages, require, character.only = TRUE)



#First we find seasonal difference , looks good at lag=20
diff(log(1+coin_sub$mean_price),lag=3) %>% ggtsdisplay()

#THen we come to non seasonal differencing, we see
log(1+coin_sub$mean_price) %>% diff() %>% diff(lag=1) %>% ggtsdisplay() #ordinary diff=1

##Proof of normality using dicky fuller
log(1+coin_sub$mean_price) %>% diff() %>% diff(lag=1) %>% adf.test()


#The significant spike at lag 1, and lag 2 in the ACF suggests a non-seasonal MA(2) component.


#Fitting the MA component
log(1+coin_sub$mean_price) %>%
  Arima(order=c(0,1,2), seasonal=c(0,1,0)) %>%
  residuals() %>% ggtsdisplay()

#We still see seasonal peacks in the ACF and PACF plot suggesting we need to try more seasonal orders
log(1+coin_sub$mean_price) %>%
  Arima(order=c(0,1,2), seasonal=c(0,1,0)) %>%
  residuals() %>% ggtsdisplay()

mean.logprice <- log(1+coin_sub$mean_price)

(inital_fit <- Arima(mean.logprice, order=c(0,1,2), seasonal=c(0,1,0)))

#We see that there are still some peraks in the ACF and PACF plot, hence we would try some other order models
# to find the best AIC value model, also as ma2 doesnt seem significant, we can try MA(1)

(updated_fit <- Arima(mean.logprice, order=c(0,1,1), seasonal=c(0,1,0)))

#our coefficients of the MA1 is significant with lesser AIC, hence we would stick to this updated model.
#We still see peaks and try models with different AR and MA orders, but we donot get better AIC than this.


#Residual analysis to detect lack of fit
plot(updated_fit$residuals)
acf(updated_fit$residuals,ylim=c(-1,1))
pacf(updated_fit$residuals,ylim=c(-1,1))
summary(updated_fit)

checkresiduals(updated_fit)
#As p-value>0.05 we donot have enough evidence to reject the null hypothesis, hence we can conclude that our mode assumptions are not being violated

#Forecasting
updated_fit %>% forecast(h=20) %>% autoplot()






