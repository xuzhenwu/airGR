\encoding{UTF-8}


\name{CreateIniStates}
\alias{CreateIniStates}


\title{Creation of the IniStates object possibly required by the CreateRunOptions functions}


\usage{
CreateIniStates(FUN_MOD, InputsModel,
  ProdStore = 350, RoutStore = 90, ExpStore = NULL,
  UH1 = NULL, UH2 = NULL,
  GCemaNeigeLayers = NULL, eTGCemaNeigeLayers = NULL,
  verbose = TRUE)
}


\arguments{
\item{FUN_MOD}{[function] hydrological model function (e.g. RunModel_GR4J, RunModel_CemaNeigeGR4J)}

\item{InputsModel}{[object of class \code{InputsModel}] see \code{\link{CreateInputsModel}} for details}

\item{ProdStore}{[numeric] production store level [mm]}

\item{RoutStore}{[numeric] routing store level [mm]}

\item{ExpStore}{(optional) [numeric] series of exponential store level (negative) [mm] for the GR6J model}

\item{UH1}{(optional) [numeric] unit hydrograph 1 levels [mm]}

\item{UH2}{(optional) [numeric] unit hydrograph 2 levels [mm]}

\item{GCemaNeigeLayers}{(optional) [numeric] snow pack [mm], possibly used to create the CemaNeige model initial state}

\item{eTGCemaNeigeLayers}{(optional) [numeric] snow pack thermal state [°C], possibly used to create the CemaNeige model initial state}

\item{verbose}{(optional) [boolean] boolean indicating if the function is run in verbose mode or not, default = \code{TRUE}}

}


\value{
[list] object of class \code{IniStates} containing the initial model internal states; it always includes the following:
         \tabular{ll}{
         \emph{$Store          }  \tab  [numeric] list of store levels (\emph{$Prod}, \emph{$Rout} and \emph{$Exp}) \cr
         \emph{$UH             }  \tab  [numeric] list of unit hydrographs levels (\emph{$UH1} and \emph{$UH2}) \cr
         \emph{$CemaNeigeLayers}  \tab  [numeric] list of CemaNeige variables (\emph{$G} and \emph{$eTG})
         }
}


\description{
Creation of the \emph{IniStates} object possibly required by the \code{\link{CreateRunOptions}} function.
}

\details{
20 numeric values are required for UH1 and 40 numeric values are required for UH2 if GR4J, GR5J or GR6J are used (respectively 20*24 and 40*24 for the hourly model GR4H).Please note that depending on the X4 parameter value that will be provided when running the model, not all the values may be used (only the first int(X4)+1 values are used for UH1 and the first 2*int(X4)+1 for UH2). \cr
\code{GCemaNeigeLayers} and \code{eTGCemaNeigeLayers} require each numeric values as many as given in \code{\link{CreateInputsModel}} with the \code{NLayersargument}. \code{eTGCemaNeigeLayers} values can be negatives.\cr
The structure of the object of class \code{IniStates} returned is always exactly the same for all models (except for the unit hydrographs levels that contain more values with GR4H), even if some states do nt exist (e.g. \emph{$UH$UH1} for GR2M).  \cr
If CemaNeige is not used, \emph{$CemaNeigeLayers$G} and \emph{$CemaNeigeLayers$eTG} are set to \code{NA}. \cr

Nota: the \code{StateEnd} objects from the outputs of \code{RunModel*} functions already respect the format given by the \code{CreateIniStates} function. 
}


\examples{
library(airGR)

## loading catchment data
data(L0123001)

## preparation of the InputsModel object
InputsModel <- CreateInputsModel(FUN_MOD = RunModel_GR4J, DatesR = BasinObs$DatesR, 
                                 Precip = BasinObs$P, PotEvap = BasinObs$E)

## run period selection
Ind_Run <- seq(which(format(BasinObs$DatesR, format = "\%d/\%m/\%Y \%H:\%M")=="01/01/1990 00:00"), 
               which(format(BasinObs$DatesR, format = "\%d/\%m/\%Y \%H:\%M")=="31/12/1991 00:00"))


### preparation of the IniStates object with low values of ProdStore and RoutStore
IniStates <- CreateIniStates(FUN_MOD = RunModel_GR4J, InputsModel = InputsModel,
                             ProdStore = 0, RoutStore = 0, ExpStore = NULL,
                             UH1 = c(0.52, 0.54, 0.15, rep(0, 17)),
                             UH2 = c(0.057, 0.042, 0.015, 0.005, rep(0, 36)),
                             GCemaNeigeLayers = NULL, eTGCemaNeigeLayers = NULL)
str(IniStates)  

## preparation of the RunOptions object
RunOptions <- CreateRunOptions(FUN_MOD = RunModel_GR4J, InputsModel = InputsModel,
                               IndPeriod_WarmUp = 0L,
                               IndPeriod_Run = Ind_Run, IniStates = IniStates)
                               
## simulation
Param <- c(257.238, 1.012, 88.235, 2.208)
OutputsModel <- RunModel_GR4J(InputsModel = InputsModel, RunOptions = RunOptions, Param = Param)

## results preview
plot(OutputsModel, Qobs = BasinObs$Qmm[Ind_Run])                               
  
  
### preparation of the IniStates object with high values of ProdStore and RoutStore
IniStates <- CreateIniStates(FUN_MOD = RunModel_GR4J, InputsModel = InputsModel,
                             ProdStore = 450, RoutStore = 100, ExpStore = NULL,
                             UH1 = c(0.52, 0.54, 0.15, rep(0, 17)),
                             UH2 = c(0.057, 0.042, 0.015, 0.005, rep(0, 36)),
                             GCemaNeigeLayers = NULL, eTGCemaNeigeLayers = NULL)
str(IniStates)  

## preparation of the RunOptions object
RunOptions <- CreateRunOptions(FUN_MOD = RunModel_GR4J, InputsModel = InputsModel,
                               IndPeriod_WarmUp = 0L,
                               IndPeriod_Run = Ind_Run, IniStates = IniStates)
                               
## simulation
Param <- c(257.238, 1.012, 88.235, 2.208)
OutputsModel <- RunModel_GR4J(InputsModel = InputsModel, RunOptions = RunOptions, Param = Param)

## results preview
plot(OutputsModel, Qobs = BasinObs$Qmm[Ind_Run]) 
}


\author{
Olivier Delaigue
}


\seealso{
\code{\link{CreateRunOptions}}
}
