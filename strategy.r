# source('/home/serg/projects/quant_r')
# install.packages("zoo")
# library("ggplot2")
library("dplyr")
library("data.table")
library('zoo')
# library("anytime")

df <- read.csv('binance.csv')
df <- as.data.table(df)
# df$Time <- anydate(df$Time)
df$time <- as.Date(df$time)

signal_bound <- function(point, level, k) {
  upper_bound <- point + (level * k)
  lower_bound <- point - (level * k)
  signal <- ifelse(point > upper_bound, 1, 0)
  signal <- ifelse(point < lower_bound, -1, signal)
  return(signal)
}

df[, ':='(
    'day' = as.numeric(format(df$time, format = "%d")),
#TODO change data formate for intraday data
    'hour' = as.numeric(format(df$time, format = "%h")),
    'minute' = as.numeric(format(df$time, format = "%Min")),
    'return' = (lag(close, 1) / close) - 1,
    'y' = (lead(close, 3) / close) - 1
)]
# df = na.omit(df, cols = c('return'))

df[, ':='(
    'ma_chg' = frollmean(return, n = 500, fill = NA, align = "center"),
    'resSigma1' = lag(high) * (1 + rollapply(return, 360, sd)),
    'resSigma2' = lag(high) * (1 + 2 * (rollapply(return, 360, sd))),
    'resSigma3' = lag(high) * (1 + 3 * (rollapply(return, 360, sd))),
    'supSigma1' = lag(low) * (1 - rollapply(return, 360, sd)),
    'supSigma2' = lag(low) * (1 - 2 * (rollapply(return, 360, sd))),
    'supSigma3' = lag(low) * (1 - 3 * (rollapply(return, 360, sd)))
)]

# Create signals
df[, ':='(
    'signal_ma' = signal_bound(return, ma_chg, 1),
    'signal_res_s1' = ifelse(high > resSigma1, 1, 0),
    'signal_res_s2' = ifelse(high > resSigma2, 1, 0),
    'signal_res_s3' = ifelse(high > resSigma3, 1, 0),
    'signal_sup_s1' = ifelse(low > supSigma1, 1, 0),
    'signal_sup_s2' = ifelse(low > supSigma2, 1, 0),
    'signal_sup_s3' = ifelse(low > supSigma3, 1, 0)
)]
# ggplot(df, aes(x = return, col = resSigma1)) +
#   geom_density() + scale_x_continuous(breaks = seq(-0.01, 0.01, 0.001))
plot(cumsum(df[signal_ma == -1, y]))
mean(df[signal_ma == -1, y])


