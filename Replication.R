library(tidyverse)
library(haven)
library(Synth)
library(devtools)
if(!require(SCtools)) devtools::install_github("bcastanho/SCtools")
library(SCtools)
library(Matching)
#install.packages("gtable")
library(gtable)


#Importing Data
rm(list = ls())
read_data <- function(df)
{
  full_path <- paste("https://github.com/scunning1975/mixtape/raw/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

texas <- read_data("texas.dta") %>% as.data.frame(.)

colnames(texas)

#Synthesize Control Replication
dataprep.out <-
  dataprep(foo = texas,
           predictors = c("poverty", "income"), #Predictors 
           predictors.op = "mean", #Method of predicting
           time.predictors.prior = 1985:1993, #Pre-Treatment stops at 1993 where project takes place
           special.predictors = list(
             list("bmprison", c(1988, 1990:1992), "mean"),
             list("alcohol", 1990, "mean"),
             list("aidscapita", 1990:1991, "mean"),
             list("black", 1990:1992, "mean"),
             list("perc1519", 1990, "mean")),
           dependent = "bmprison",
           unit.variable = "statefip", #Numeric representation of unit
           unit.names.variable = "state", #Name of unit
           time.variable = "year", #Time inidicator variable
           treatment.identifier = 48, #Texas No.48 as the treatment
           controls.identifier = c(1,2,4:6,8:13,15:42,44:47,49:51,53:56), #Synthesize control pool excluding Texas
           time.optimize.ssr = 1985:1993, 
           time.plot = 1985:2000
  )

synth.out <- synth(dataprep.out) 
path.plot(synth.out, dataprep.out, Ylab = "Incarceration Rates", Xlab = "Year", Legend= c("Texas","Synthetic Texas"))
abline(v=1993, col = "gray", lty = 2)
arrows(x0 = 1991, y0 = 55000, x1 = 1993, y1 = 55000, col = "black", length = .1)
text(1988.5, 55000,
       "Policy Change",
       cex = .8)

#Gap Plot
gaps.plot(synth.res = synth.out,
          dataprep.res = dataprep.out,
          Ylab = "gap in black male incarceration",
          Xlab = "year",
          Main = NA)
abline(v=1993, col = "gray", lty = 2)
arrows(x0 = 1991, y0 = 10000, x1 = 1993, y1 = 10000, col = "black", length = .1)
text(1988.5, 10000,
     "Policy Change",
     cex = .8)

#in-space placebo replication
placebos <- generate.placebos(dataprep.out, synth.out, Sigf.ipop = 3, strategy = "multisession") 
plot_placebos(placebos) 
mspe.plot(placebos, discard.extreme = TRUE, mspe.limit = 1, plot.hist = TRUE)


########################################################################################################################
#Extension (placebo-in-time) Control ends at 1990
dataprep.it <- 
    dataprep(foo = texas,
             predictors = c("poverty", "income"), #Predictors 
             predictors.op = "mean", #Method of predicting
             time.predictors.prior = 1985:1990, #Placebo untill 1990
             special.predictors = list(
               list("bmprison", c(1988, 1990:1992), "mean"),
               list("alcohol", 1990, "mean"),
               list("aidscapita", 1990:1991, "mean"),
               list("black", 1990:1992, "mean"),
               list("perc1519", 1990, "mean")),
             dependent = "bmprison",
             unit.variable = "statefip", #Numeric representation of unit
             unit.names.variable = "state", #Name of unit
             time.variable = "year", #Time inidicator variable
             treatment.identifier = 48, #Texas No.48 as the treatment
             controls.identifier = c(1,2,4:6,8:13,15:42,44:47,49:51,53:56), #Synthesize control pool excluding Texas
             time.optimize.ssr = 1985:1990, 
             time.plot = 1985:2000
    )
synth.it <- synth(dataprep.it)

path.plot(synth.res    = synth.it,
          dataprep.res = dataprep.it,
          Ylab         = c("Incarceration Rates"),
          Xlab         = c("Year"),
          Legend       = c("Texas","Synthetic Texas"),
          Legend.position = c("bottomright"), Main = "In-Time Placebo"
)

abline(v=1990, col = "gray", lty = 2)
arrows(x0 = 1989, y0 = 25000, x1 = 1990, y1 = 25000, col = "black", length = .1)
text(1987.5, 25000,
     "Placebo Treatment", cex = 0.7)

#############################################################################################################################

#Contributor
round(synth.out$solution.w,2) #6 #12 #22
#par(mfrow=c(2,2)) 

#without no.12 
dataprep.n2 <- 
  dataprep(foo = texas,
           predictors = c("poverty", "income"), #Predictors 
           predictors.op = "mean", #Method of predicting
           time.predictors.prior = 1985:1993, 
           special.predictors = list(
             list("bmprison", c(1988, 1990:1992), "mean"),
             list("alcohol", 1990, "mean"),
             list("aidscapita", 1990:1991, "mean"),
             list("black", 1990:1992, "mean"),
             list("perc1519", 1990, "mean")),
           dependent = "bmprison",
           unit.variable = "statefip", #Numeric representation of unit
           unit.names.variable = "state", #Name of unit
           time.variable = "year", #Time inidicator variable
           treatment.identifier = 48, #Texas No.48 as the treatment
           controls.identifier = c(1,2,4:6,8:11,13,15:42,44:47,49:51,53:56), #Synthesize control pool excluding Texas
           time.optimize.ssr = 1985:1993, 
           time.plot = 1985:2000
  )
synth.n2 <- synth(dataprep.n2)
path.plot(synth.n2, dataprep.n2, Ylab = "Incarceration Rates", Xlab = "Year", Legend= c("Texas","Synthetic Texas"), Main = "Without Florida")
abline(v=1993, col = "gray", lty = 2)
arrows(x0 = 1991, y0 = 55000, x1 = 1993, y1 = 55000, col = "black", length = .1)
text(1988.5, 55000,
     "Policy Change",
     cex = .8)

#without no.12 and no.22 
dataprep.n1 <- 
  dataprep(foo = texas,
           predictors = c("poverty", "income"), #Predictors 
           predictors.op = "mean", #Method of predicting
           time.predictors.prior = 1985:1993, 
           special.predictors = list(
             list("bmprison", c(1988, 1990:1992), "mean"),
             list("alcohol", 1990, "mean"),
             list("aidscapita", 1990:1991, "mean"),
             list("black", 1990:1992, "mean"),
             list("perc1519", 1990, "mean")),
           dependent = "bmprison",
           unit.variable = "statefip", #Numeric representation of unit
           unit.names.variable = "state", #Name of unit
           time.variable = "year", #Time inidicator variable
           treatment.identifier = 48, #Texas No.48 as the treatment
           controls.identifier = c(1,2,4:6,8:11,13,15:21,23:42,44:47,49:51,53:56), #Synthesize control pool excluding Texas
           time.optimize.ssr = 1985:1993, 
           time.plot = 1985:2000
  )
synth.n1 <- synth(dataprep.n1)
path.plot(synth.n1, dataprep.n1, Ylab = "Incarceration Rates", Xlab = "Year", Legend= c("Texas","Synthetic Texas"), Main = "Only California")
abline(v=1993, col = "gray", lty = 2)
arrows(x0 = 1991, y0 = 55000, x1 = 1993, y1 = 55000, col = "black", length = .1)
text(1988.5, 55000,
     "Policy Change",
     cex = .8)
#without no.12, no.22, and no.6
dataprep.n0 <- 
  dataprep(foo = texas,
           predictors = c("poverty", "income"), #Predictors 
           predictors.op = "mean", #Method of predicting
           time.predictors.prior = 1985:1993, #Placebo untill 1990
           special.predictors = list(
             list("bmprison", c(1988, 1990:1992), "mean"),
             list("alcohol", 1990, "mean"),
             list("aidscapita", 1990:1991, "mean"),
             list("black", 1990:1992, "mean"),
             list("perc1519", 1990, "mean")),
           dependent = "bmprison",
           unit.variable = "statefip", #Numeric representation of unit
           unit.names.variable = "state", #Name of unit
           time.variable = "year", #Time inidicator variable
           treatment.identifier = 48, #Texas No.48 as the treatment
           controls.identifier = c(1,2,4:5,8:11,13,15:21,23:42,44:47,49:51,53:56), #Synthesize control pool excluding Texas
           time.optimize.ssr = 1985:1993, 
           time.plot = 1985:2000
  )
synth.n0 <- synth(dataprep.n0)
path.plot(synth.n0, dataprep.n0, Ylab = "Incarceration Rates", Xlab = "Year", Legend= c("Texas","Synthetic Texas"), Main = "None in the Original Pool")
abline(v=1993, col = "gray", lty = 2)
arrows(x0 = 1991, y0 = 55000, x1 = 1993, y1 = 55000, col = "black", length = .1)
text(1988.5, 55000,
     "Policy Change",
     cex = .8)

#without no.22
dataprep.n6 <- 
  dataprep(foo = texas,
           predictors = c("poverty", "income"), #Predictors 
           predictors.op = "mean", #Method of predicting
           time.predictors.prior = 1985:1993, #Placebo untill 1990
           special.predictors = list(
             list("bmprison", c(1988, 1990:1992), "mean"),
             list("alcohol", 1990, "mean"),
             list("aidscapita", 1990:1991, "mean"),
             list("black", 1990:1992, "mean"),
             list("perc1519", 1990, "mean")),
           dependent = "bmprison",
           unit.variable = "statefip", #Numeric representation of unit
           unit.names.variable = "state", #Name of unit
           time.variable = "year", #Time inidicator variable
           treatment.identifier = 48, #Texas No.48 as the treatment
           controls.identifier = c(1,2,4:6,8:13,15:21,23:42,44:47,49:51,53:56), #Synthesize control pool excluding Texas
           time.optimize.ssr = 1985:1993, 
           time.plot = 1985:2000
  )
synth.n6 <- synth(dataprep.n6)
path.plot(synth.n6, dataprep.n6, Ylab = "Incarceration Rates", Xlab = "Year", Legend= c("Texas","Synthetic Texas"), Main = "Without Louisiana")
abline(v=1993, col = "gray", lty = 2)
arrows(x0 = 1991, y0 = 55000, x1 = 1993, y1 = 55000, col = "black", length = .1)
text(1988.5, 55000,
     "Policy Change",
     cex = .8)

#without no.6
dataprep.n6 <- 
  dataprep(foo = texas,
           predictors = c("poverty", "income"), #Predictors 
           predictors.op = "mean", #Method of predicting
           time.predictors.prior = 1985:1993, #Placebo untill 1990
           special.predictors = list(
             list("bmprison", c(1988, 1990:1992), "mean"),
             list("alcohol", 1990, "mean"),
             list("aidscapita", 1990:1991, "mean"),
             list("black", 1990:1992, "mean"),
             list("perc1519", 1990, "mean")),
           dependent = "bmprison",
           unit.variable = "statefip", #Numeric representation of unit
           unit.names.variable = "state", #Name of unit
           time.variable = "year", #Time inidicator variable
           treatment.identifier = 48, #Texas No.48 as the treatment
           controls.identifier = c(1,2,4:5,8:13,15:42,44:47,49:51,53:56), #Synthesize control pool excluding Texas
           time.optimize.ssr = 1985:1993, 
           time.plot = 1985:2000
  )
synth.n6 <- synth(dataprep.n6)
path.plot(synth.n6, dataprep.n6, Ylab = "Incarceration Rates", Xlab = "Year", Legend= c("Texas","Synthetic Texas"), Main = "Without California")
abline(v=1993, col = "gray", lty = 2)
arrows(x0 = 1991, y0 = 55000, x1 = 1993, y1 = 55000, col = "black", length = .1)
text(1988.5, 55000,
     "Policy Change",
     cex = .8)



