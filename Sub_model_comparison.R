# getting ready -----------------------------------------------------------
library(cocor)
rm(list = ls())

# read data ---------------------------------------------------------------
subdata <- read.csv("data.csv")
cocor(~SIFM + subject | CPM + subject,subdata)
cocor.dep.groups.overlap(cor(subdata$subject,subdata$SIFM),
                         cor(subdata$subject,subdata$CPM),
                         cor(subdata$SIFM,subdata$CPM),
                         length(subdata$subject))
