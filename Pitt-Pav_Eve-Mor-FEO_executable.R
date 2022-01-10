#### --- Pavlidis-Pittendrigh Model simulated with the Euler integration method --- ####
#### --- Executable --- ####

#Date: 2021 September 24
#Author: Danilo Flores
#University of Sao Paulo
#Filename: "Pitt-Pav_Eve-Mor-FEO_executable.R"

#This code executes simulations of the Pittendrigh-Pavlidis model, by using the functions
#written in the scripts
# - "Pitt-Pav_Eve-Mor-FEO_functions.R"
# - "Pitt-Pav_Eve-Mor-FEO_functions-2.R"
#The code is adapted from a previous implementation of the model in Java,
#in the CircadianDynamix extension of the Neurodynamix II software
# "Friesen WO, and Friesen JA (2010) Neurodynamix II: Concepts of neurophysiology
#  illustrated by computer simulations, Oxford University Press, New York"


##### ---- USER input data ---- ######
#Defining the folder (directory) where the INPUT data is stored
inputDir <- "Data/ParamTables"
#Defining the input file that contains the oscillator parameter (.xlsx or .csv)
parameterFile <- "Test-parameters2.csv"
#Defining the files that contain the light pulse information
#For constant conditions, replace file name with NA
evePulseFile <- "Test-pulses.csv"
morPulseFile <- NA
FEOPulseFile <- NA
#Defining the folder (directory) where the OUTPUT data will be stored
outputDir <- "Data/Results"
#Name of the output file
outputFile <- "Test-results.csv"
#Project name (optional) - To ingnore, replace the names with NA
projectName <- "Test-simulation"
#Number of days in the simulation
nDays <- 200


### ---- Installs and loads the required packages ---- ###

#Install and load the pacman package
if (!requireNamespace("pacman", quietly = TRUE)){
  install.packages("pacman")}
library(pacman)

#Install/load other packages
pacman::p_load(tidyverse, data.table, readxl, here)

### ---- Reads the functions from other scripts ---- ###

#Loads the functions from the scripts.
source("Functions/Pitt-Pav_Eve-Mor-FEO_functions.R")
source("Functions/Pitt-Pav_Eve-Mor-FEO_functions-2.R")


### ---- Execution code ---- ###

#Preparing the model
#Defining the paramenters
paramPath <- paste0(inputDir,"/",parameterFile)
paramData <-  readParameters(paramPath)
#Defining the pulse schedules
if(!is.na(evePulseFile)){
  evePulsePath <- paste0(inputDir,"/",evePulseFile)
  evePulseData <- readPulseSchedule(evePulsePath)
} else {evePulseData <- NA}
if(!is.na(morPulseFile)){
  morPulsePath <- paste0(inputDir,"/",morPulseFile)
  morPulseData <- readPulseSchedule(morPulsePath)
} else {morPulseData <- NA}
if(!is.na(FEOPulseFile)){
  FEOPulsePath <- paste0(inputDir,"/",FEOPulseFile)
  FEOPulseData <- readPulseSchedule(FEOPulsePath)
} else {FEOPulseData <- NA}

#Simulation
system.time(
  simulateModel(nDays=nDays,params=paramData,evePulses=evePulseData,
                morPulses=morPulseData,FEOPulses=FEOPulseData)
)

#Creating the raster variables from the S state varaibles
outTableRast <- bind_cols(outTable,completeRastGerenerate(outTable)[,-1])

#Saving the results to a file
dir.create(outputDir,showWarnings = F)
outputPath <- paste0(outputDir,"/",outputFile)
write.csv(outTableRast,outputPath,row.names=F)


#Saving a log file with the simulation details
logData <- data.frame(             #Content of the log file
  "Time_and_date" = Sys.time(),
  "Project" = projectName,
  "Output_file" = outputFile,
  "Parameter_File" = parameterFile,
  "Evening_pulse_file" = evePulseFile,
  "Morning_pulse_file" = morPulseFile,
  "FEO_pulse_file" = FEOPulseFile
)
logDir <- "Data/Log-simulations"              #Defines the folder to store the log file
dir.create(logDir,showWarnings = F)           #Creates the folder to store the log file
logFileName <- gsub("^.*/","",outputFile)     #Renames the outputFile
logFileName <- paste0(logDir,"/Log_",gsub(".csv",".txt",logFileName))
write.table(logData,logFileName,row.names=F,sep="\t")  #Saves the data to the log file

#Cleans the working space
rm(list=ls())

