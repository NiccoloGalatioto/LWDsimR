#===================================================================
#
# LWDsimR
#
# University of Berne, Mobiliar Lab for Natural Risks, 2017
# Version 2, 2018
#
# Niccolo Galatioto & Andreas Paul Zischg
#
# for detailed instructions please see the user manual: "LWDsimR: Simulation of Woody Debris Dynamics during floods"
#
#
# START
#
#===================================================================

# define working directory

wd<-getwd()
setwd(wd)

# define data directory

dd<-gsub("Transportmodel","Project",wd)

# ------------------------------------------------------------------

# load packages
library(FNN)
library(rgdal)
library(abind)

# ******************************************************************
# Define time steps and free parameters
# ******************************************************************

# define Input-times teps from BASEMENT
TRT<- 3600                #Total run time of BASEMENT             [s]
TSB<- 60                  #Output time step BASEMENT              [s]
TS<-TRT/TSB               #Total Number of Iterations in BASEMENT [#]

# define time steps for woodsimulation
TSW<-3                    #timestep for woodsimulation            [s]
TSWT<- TSB/TSW            #Number of Iterations in woodsimulation [#]

# define time steps for saving results
nsave<-3                  #Size of time step saved in array       [s]
nwrite<-10                #Safetycopy of ws on harddrive          [# of TS]

# define free model parameters
Cd<-    0.8               #Drag coefficient                       []
g<-     9.81              #Gravitation                            [m/s^2]
rho<-   1                 #Density of the water                   [kg/m^3]  
sigma<- 1                 #Density of the log                     [kg/m^3] 
mu<-    1                 #Friction between log and ground        []
r<-     2                 #Exponent for IDW-Interpolation         []
dnr<-   1                 #Threshold relation for transport from depth to log diameter without rootwad
dwr<-   1.7               #Threshold relation for transport from depth to log diameter with rootwad

#define meta-information
vkl<-   TRUE              #Consider entrapments at bridges
bvers<- 2.5               #BASEMENT version (2.5 or 2.6)
name<-  "Zulg"            #Name of the BASEMENT-Input Files
name2dm<-"Mesh_5_20_1000" #Name of the Mesh (.2dm file)
# ******************************************************************

#load functions and inputdata

source('Functions.R')     #all functions
source('Inputdaten.R')    #all inputdata
source('LWDsimR.R')       #the model 


#*******************************************************************
# START SIMULATION
#*******************************************************************

a.res<-LWDsimR()

#*******************************************************************
# END SIMULATION
#*******************************************************************

# Extract jammed logs on bridges 

if(vkl==T){
  for(k in 1:length(m.Obstacles_Info[,1])){
    m.Obstacles_Info[k,"Amount"]<-sum(a.res[,"Obs_Nr",dim(a.res)[3]-1]==k)
    vkl_trees<-which(a.res[,"Obs_Nr",dim(a.res)[3]-1]==k)
    m.Obstacles_Info[k,"Volume"]<-sum(0.4*d.Wood[vkl_trees,"Length"]*(d.Wood[vkl_trees,"DBH"]^2))
  }
}

# Save the results

save(list = ls(all.names = TRUE),file=paste(dd,"/Results/Results.RData",sep=""),envir = .GlobalEnv)
# ------------------------------------------------------------------
