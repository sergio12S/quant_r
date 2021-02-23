# sudo apt-get install libcurl4-gnutls-dev
# install.packages("request",  dependencies = TRUE)
# install.packages("jsonlite")

library("request")
library("jsonlite")
library("data.table")

# req <- GET('https://aipricepatterns.com/api/api/quantstrat?name=ML%20DT&days=1')
req <- GET('https://aipricepatterns.com/api/api/quantstrat', query=list(name='ML DT', days=2))

df <- fromJSON(rawToChar(req$content))
df <- data.frame(df)
# df$returns.Time <- as.Date(df$returns.Time)
plot(cumsum(df$returns.Result), type='l')
