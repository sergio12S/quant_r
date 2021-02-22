library("R6")

backtester <- setClass(
    "Backtester",
    slots = c(
        position_data = "character",
        status = "character",
        count_lag = "numeric"
    ),
    prototype = list(
        position_data = character(5),
        statis = "close",
        count_lag = 0
    )
)