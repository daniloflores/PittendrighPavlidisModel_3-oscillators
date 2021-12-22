#### --- Pavlidis-Pittendrigh Model with the Euler Method --- ####
#### --- EXTRA functions --- ####

#This code creates some extra functions needed to run the simulations.


ndAnalysis <- function(timeVar, oscillVar){
  #Returns amplitude and period along the time-series
  #Updated and optimized on Jul 01 2021
  
  #Variables
  size <- length(oscillVar)
  #tLastMin <- 0
  tLastMax <- LastMin <- LastMax <- 0
  #Vector indicating minima (+2) and maxima (-2), otherwhise = 0
  minMaxFlag <- c(NA,diff(sign(diff(oscillVar))),NA)
  #Empty Data frame to store current period and amplitude at each time point
  Analysis <- data.frame("Time" = timeVar,
                         "Period" = rep(NA,size),
                         "Amplitude" = rep(NA,size),
                         "Min" = rep(NA,size),
                         "Max" = rep(NA,size))
  Analysis$Min[1] <- Analysis$Max[1] <- 0
  
  #Iterative function to calculate period and amplitude
  #Goes point by point in the data and updates the period and amplitude
  #when new minima and maxima are found in the data
  for (x in seq(2,(size-1))){
    if (minMaxFlag[x]== 2){                         #At each new minimum
      LastMin <- oscillVar[x]                       #Updates the value of the minimum (temp. variable)
      Analysis$Min[x] <- LastMin                    #Updates the value of the minimum in the table
      Analysis$Amplitude[x] <- LastMax-LastMin      #Updates the amplitude
    } else if (minMaxFlag[x]== -2){                              #At each new maximum
      Analysis$Period[x] <- (timeVar[x] - tLastMax + 0.001)*24   #Updates the period
      tLastMax <- timeVar[x]                        #Updates the time of the maximum
      LastMax <- oscillVar[x]                       #Updates the value of the maximum (temp. variable)
      Analysis$Max[x] <- LastMax                #Updates the value of the maximum in the table
    } 
  }
  
  #Fill the NA's in the table by using the strategy "last observation carried forward"
  Analysis$Period <- nafill(Analysis$Period,type="locf")
  Analysis$Amplitude <- nafill(Analysis$Amplitude,type="locf")
  Analysis$Min <- nafill(Analysis$Min,type="locf")
  Analysis$Max <- nafill(Analysis$Max,type="locf")
  
  #Function returns the final result in a table
  Analysis
  
}


lightActogram <- function (timeVar, lightVar,negativeLight=FALSE,displace=0.05){
  #Converts light data to actogram format
  
  #Variables
  size <- length(lightVar)
  light <- data.frame(rep(NA,size),rep(NA,size))
  names(light) = c("RastLight", "PreRastLight")
  #Converting light data to Rast values
  if(negativeLight){ #light pulse has negative amplitude
    lightVar[lightVar<0] <- floor(timeVar[lightVar<0])*(-0.5)-displace
    lightVar[lightVar==0] <- 14
  }else{  #light pulse has positive amplitude
    lightVar[lightVar>0] <- floor(timeVar[lightVar>0])*(-0.5)-displace
    lightVar[lightVar==0] <- 14
  }
  #Preparing indexes to select data segments for RastLight and PreRastLight
  #Isolates indexes 1-500, 1001-1500, 2001-2500, etc
  indexes <- (seq(size)%%1000)>=1 & (seq(size)%%1000)<=500
  #Selecting only 1 every 2 data points from lightVar
  selectlight <- lightVar[seq(1,size,2)]
  #Inserting the data in the final dataframe
  light$RastLight[indexes] <- 10 #indexes filled with 10's
  light$RastLight[!indexes] <-  selectlight[1:sum(!indexes)] #complement of indexes is filled with data
  light$PreRastLight[!indexes] <- 10 #complement of indexes filled with 10's
  light$PreRastLight[indexes] <-  (selectlight-0.5)[1:sum(indexes)] #indexes filled with data
  #Funcion returns the dataframe
  light
}


rastGenerate <- function(timeVar, oscillVar, ampl, min, threshold,invert=F){
  #Automatically generates actogram (Rast) data from the
  #raw state variable
  
  #Considers activity when variable exceeds the desired threshold.
  #If invert is TRUE, considers activity when variable is BELOW the threshold.
  #If threshold is positive, it is a proportion of the amplitude, complementary
  #to the given value (1-value). The minimum of the variable must be added to 
  #the threshold. If negative, the threshold is the value itself times -1.
  #Amplitude and Minimum continuous values can be obtained with the function
  #ndAnalysis.
  if (threshold>0){
    activ <- 1*(oscillVar>((1-threshold)*ampl+min))
  } else {
    activ <- 1*(oscillVar>(-threshold))
  }
  if(invert) activ<-1*!activ
  #Removes NA's from activity
  activ[is.na(activ)]<-0
  #Uses the "lightActogram" function to generate raster variables
  #from discrete values (0's and 1's)
  rastActiv <- lightActogram(timeVar, activ,displace=0)
  #Renames columns to activity instead of light
  names(rastActiv) <- c("PlotRastActiv", "PrePlotRastActiv")
  #Returns the data frame
  rastActiv
}


completeRastGerenerate<-function(dados,threshold=0.3,invert=F){
  #Generating new rast series from state variables
  #Crating a function to do that automatically
  
  #Automatically generate rast variables from a data set (eve + mor + FEO) and
  #return a new complete and usable data set
  
  #Calculate amplitude, period, max and min for each time point
  parameters<-ndAnalysis(dados$Time.sec.,dados$Se)
  #Generate rast variables from the Se state variable (evening
  #oscillator) using the chosen threshold value
  rastEve<-rastGenerate(parameters$Time,dados$Se,parameters$Amplitude,
                        parameters$Min,threshold,invert)
  #Create a new object with everything needed to plot the data
  #and to perform further analyses.
  newDados<-data.frame(
    Time.sec.=dados$Time.sec.,
    PlotRasterSe=rastEve$PlotRastActiv,
    PrePlotRasterSe=rastEve$PrePlotRastActiv
  )
  #Repeat the process for the morning oscillator if present
  if("Sm" %in% names(dados)){
    parameters<-ndAnalysis(dados$Time.sec.,dados$Sm)
    rastMor<-rastGenerate(parameters$Time,dados$Sm,parameters$Amplitude,
                          parameters$Min,threshold,invert)
    #Adds the morning data, if morning oscillator is present
    newDados<-cbind(newDados,
                    PlotRasterSm=rastMor$PlotRastActiv,
                    PrePlotRasterSm=rastMor$PrePlotRastActiv
    )
  }
  #Repeat the process for the FEO oscillator if present
  if("SFEO" %in% names(dados)){
    parameters<-ndAnalysis(dados$Time.sec.,dados$SFEO)
    rastFEO<-rastGenerate(parameters$Time,dados$SFEO,parameters$Amplitude,
                          parameters$Min,threshold,invert)
    #Adds the morning data, if morning oscillator is present
    newDados<-cbind(newDados,
                    PlotRasterSFEO=rastFEO$PlotRastActiv,
                    PrePlotRasterSFEO=rastFEO$PrePlotRastActiv
    )
  }
  
  #Return the final object
  newDados
}
