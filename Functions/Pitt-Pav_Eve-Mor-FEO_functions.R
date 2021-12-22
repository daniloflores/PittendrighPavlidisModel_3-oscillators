#### --- Pavlidis-Pittendrigh Model with the Euler Method --- ####
#### --- Code of the functions --- ####

#This code adds the FEO oscillator to the model.
#It was derived from the optimized code implemented in the script
#"Pitt-Pav_Jul-01-2021.R", which had only the E and M oscillators.
#This implementation is adapted from the Circadiandynamix extension of the
#Neurodynamix software by Otto Friesen, which was implemented in Java.

#Update Jul 13 2021 - output table converted to matrix, to make code faster

#Required packages
library(tidyverse)
library(data.table)

### ---- Functions ---- ###

createParameters <- function(ae=0.85,be=0.3,ce=0.8,de=0.5,
                             am=0.85,bm=0.3,cm=0.8,dm=0.5,
                             aFEO=0.85,bFEO=0.3,cFEO=0.8,dFEO=0.5,
                             Cem=0,Cme=0,CeFEO=0,CFEOe=0,CmFEO=0,CFEOm=0,
                             saveToFile="",fileDir=""){
  #Creates a table with the oscillator parameters.
  #If, instead, you want to read a table with parameter values from a file,
  #use the "readParameter" function.
  
  paramData <- as.data.frame(as.list(environment()))[1:18]
  
  #If an output file name was given in "saveToFile", saves the table to that file
  if(saveToFile!=""){
    outData <- data.frame(Parameter=names(paramData),Value=as.numeric(paramData))
    outPath <- paste0(fileDir,"/",saveToFile)
    write.csv(outData,outPath,row.names=F)
  }
  else {return(paramData)}    #Otherwise, function returns the table
}

readParameters <- function(fileName){
  ###Reads from file the table with the oscillator parameters###
  #This is an alternative to createParameters, if you want to read the parameter
  #values from a file, instead of creating them within R.
  
  #Checks if the csv file separator is ";"
  firstLine <- readLines(fileName,n=1)
  sepSemiColon <- grepl(";",firstLine)
  #Reads the data from file according to the csv file separator
  if(sepSemiColon) {
    read.csv(fileName,sep=";") %>%
      column_to_rownames("Parameter") %>% t %>% as.data.frame()
  } else {
    read.csv(fileName) %>%
      column_to_rownames("Parameter") %>% t %>% as.data.frame()
  }
}

setOscillators<-function(parameters){
  #Function to set the oscillator parameters
  eve <<- list()
  mor <<- list()
  FEO <<- list()
  #Definign the values of the parameters
  eve$a <<- parameters$ae
  eve$b <<- parameters$be
  eve$c <<- parameters$ce
  eve$d <<- parameters$de
  mor$a <<- parameters$am
  mor$b <<- parameters$bm
  mor$c <<- parameters$cm
  mor$d <<- parameters$dm
  FEO$a <<- parameters$aFEO
  FEO$b <<- parameters$bFEO
  FEO$c <<- parameters$cFEO
  FEO$d <<- parameters$dFEO
  #Defining the coupling terms
  Cem <<- parameters$Cem
  Cme <<- parameters$Cme
  CeFEO <<- parameters$CeFEO
  CFEOe <<- parameters$CFEOe
  CmFEO <<- parameters$CmFEO
  CFEOm <<- parameters$CFEOm
  #Initial values of the oscillator variables (not to be changed)
  eve$R <<- 1.1
  eve$S <<- 1.1
  mor$R <<- 1.1
  mor$S <<- 1.1
  FEO$R <<- 1.1
  FEO$S <<- 1.1
  #Kyner constants (not to be changed)
  k1 <<- 1
  k2 <<- 100
}

createTimeVar <- function(nDays=10){
  #Function to create the time variable based on the number of days.
  #Defining the time interval between each calculation step
  dt. <<- 0.001
  #Calculates a "dummy" delta time that is multiplied by a corretion term
  #needed to replicate the results from Neurodynamix (Prof. Friesen's software)
  correction <<- 6.786
  deltaTime <<- dt.*correction
  #Defines the number of days to simulate
  nDays <<- nDays
  #Time values for the whole simulation
  times <<- seq(0,nDays,dt.)
}

createPulseSchedule <- function (pulseDays=seq(3,8),pulseTime=10,
                                 pulseAmpl=1,pulseDur=1,saveToFile="",fileDir="") {
  #Function to create the light or food schedule, based on light pulse information
  #Instructions
  #Pulse time (0-24h), amplitude and duration (in hours) should be either a single
  #value to be applied to all pulses, or one value for each pulse having a total count
  #that equals the length of the "pulseDays" vector.
  
  #Create a data frame with the pulse information
  pulseSchedule <- data.frame(
    day = pulseDays,
    time = pulseTime,
    dur = pulseDur,
    amp = pulseAmpl
  )
  
  #If an output file name was given in "saveToFile", saves the table to that file
  
  if(saveToFile!=""){
    outPath <- paste0(fileDir,"/",saveToFile)
    write.csv(pulseSchedule,outPath,row.names=F)
  }
  else {return(pulseSchedule)}    #Otherwise, function returns the table
  
}

readPulseSchedule <- function(fileName) {
  ### Reads from file the light or food schedule ###
  #This is an alternative to createPulseSchedule, in case the pulse
  #data is stored in a file.
  
  #Checks if the csv file separator is ";"
  firstLine <- readLines(fileName,n=1)
  sepSemiColon <- grepl(";",firstLine)
  #Reads the data from file according to the csv file separator
  if(sepSemiColon) {
    read.csv(fileName,sep=";")
  } else {
    read.csv(fileName)
  }
}

createPulseVar <- function(pulseSchedule,empty=F) {
  #Creates a continuous light/food variable from the provided pulse times
  #durations and amplitudes
  
  if(empty){
    #If the "empty" argument is set to true, creates a vector with
    #all variable values at zero (constant darkness/ad libitum food)
    pulseData <- data.frame(time=times,
                            pulseVar=0) %>%
      mutate(time=round(time,digits=3))
  } else {
    #If "empty" argument is false, creates the light/food variable with
    #the values provided
    #Light/food pulse data
    pulseInfo <- data.frame(
      start = pulseSchedule$day + pulseSchedule$time/24,
      end = pulseSchedule$day+pulseSchedule$time/24+pulseSchedule$dur/24
    )
    #Processing the amplitude
    ampInfo <- pulseInfo %>%
      bind_cols(amp=pulseSchedule$amp)
    pulseDataPoints <- tibble(start=c(0,ampInfo$start-0.001),
                              end=c(0,ampInfo$end+0.001),
                              amp=0) %>%
      bind_rows(ampInfo) %>%
      pivot_longer(cols=c(start,end),values_to="time") %>%
      rename(pulseVar="amp") %>%
      select(-name)
    #Creating the final variable
    prePulseData <- data.frame(time=times) %>%
      full_join(pulseDataPoints,by="time") %>%
      arrange(time) %>%
      mutate(pulseVar=nafill(pulseVar,type="locf"))
    pulseData <- data.frame(time=times) %>%
      left_join(prePulseData,by="time") %>%
      mutate(time=round(time,digits=3)) %>%
      mutate(pulseVar=nafill(pulseVar,type="locf")) %>%
      rename(Time.sec.="time") %>%
      unique
  }
  
  #Returns the vector
  pulseData
}

createOutTable <- function(eveLight,morLight,food){
  #Create an output data frame to store the values of the variables
  outTable <<- data.frame(Time.sec.=times,
                          Se=c(eve$S,rep(NA,length(times)-1)),
                          Re=c(eve$R,rep(NA,length(times)-1)),
                          Sm=c(eve$S,rep(NA,length(times)-1)),
                          Rm=c(mor$R,rep(NA,length(times)-1)),
                          SFEO=c(FEO$S,rep(NA,length(times)-1)),
                          RFEO=c(FEO$R,rep(NA,length(times)-1))) %>%
    #Adds the light/food data and rename appropriately
    bind_cols(eveLight[-1]) %>%
    rename(Lighte="pulseVar") %>%
    bind_cols(morLight[-1]) %>%
    rename(Lightm="pulseVar") %>%
    bind_cols(food[-1]) %>%
    rename(Food="pulseVar") %>%
    as.matrix
}

eulerPittPav <- function(){
  #Simulation: solves the equation, by calculating the values
  #for evening, morning and FEO variables S and R at each interval dt.
  
  #Following the Euler integration method, the new value of a variable
  #equals its previous value plus the calculated derivative times dt (deltaTime)
  for (i in seq(nDays*1000)){
    #i=1
    #Calculates a new value for the Kyner term
    eveK <- k1/(1+k2*(eve$R^2))
    morK <- k1/(1+k2*(mor$R^2))
    FEOK <- k1/(1+k2*(FEO$R^2))
    #Obtains the light level
    eveL <- outTable[i,"Lighte"]
    morL <- outTable[i,"Lightm"]
    food <- outTable[i,"Food"]
    #Calculates the derivative for the state variables
    eve$dS <- (eve$R - eve$a*eve$S + Cme*mor$S + CFEOe*FEO$S)
    eve$dR <- (eve$R - eve$c*eve$S -eve$b*(eve$S^2) +(eve$d-eveL) +eveK)
    mor$dS <- (mor$R - mor$a*mor$S + Cem*eve$S + CFEOm*FEO$S)                      
    mor$dR <- (mor$R - mor$c*mor$S -mor$b*(mor$S^2) +(mor$d-morL) +morK)
    FEO$dS <- (FEO$R - FEO$a*FEO$S + CeFEO*eve$S + CmFEO*mor$S)                      
    FEO$dR <- (FEO$R - FEO$c*FEO$S -FEO$b*(FEO$S^2) +(FEO$d-food) +FEOK)
    #Calculates the new value for the state variables
    eve$S <- eve$S+eve$dS*deltaTime                        
    eve$R <- eve$R+eve$dR*deltaTime 
    mor$S <- mor$S+mor$dS*deltaTime                        
    mor$R <- mor$R+mor$dR*deltaTime
    FEO$S <- FEO$S+FEO$dS*deltaTime                        
    FEO$R <- FEO$R+FEO$dR*deltaTime
    #If R state variable is negative, replaces with zero
    if(eve$R<0) {eve$R <- 0}                   
    if(mor$R<0) {mor$R <- 0}                   
    if(FEO$R<0) {FEO$R <- 0}
    #Saves the new values in the output data.frame
    outTable[i+1,"Se"] <<- eve$S
    outTable[i+1,"Re"] <<- eve$R
    outTable[i+1,"Sm"] <<- mor$S
    outTable[i+1,"Rm"] <<- mor$R
    outTable[i+1,"SFEO"] <<- FEO$S
    outTable[i+1,"RFEO"] <<- FEO$R
  }
}

simulateModel <- function(nDays=40,params,evePulses=NA,morPulses=NA,FEOPulses=NA) {
  #Performs the simulation according to the given parameters
  
  ## First, creates the oscillators, time variable and light/food pulse variables.
  #Setting the model (oscillators and time variable)
  setOscillators(params)   
  createTimeVar(nDays=nDays)
  #Creating the light and food variables
  if(length(evePulses)==1) {eveLight <- createPulseVar(empty=T)}
  else {eveLight <- createPulseVar(evePulses)}
  if(length(morPulses)==1) {morLight <- createPulseVar(empty=T)}
  else {morLight <- createPulseVar(morPulses)}
  if(length(FEOPulses)==1) {food <-  createPulseVar(empty=T)}
  else {food <-  createPulseVar(FEOPulses)}
  #Creating the output table
  createOutTable(eveLight,morLight,food)
  
  #Executes the simulation
  eulerPittPav()
  
  #Converts the output table from matrix to data frame
  outTable <<- as.data.frame(outTable)
}

