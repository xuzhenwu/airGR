CreateIniStates <- function(FUN_MOD, InputsModel,
                            ProdStore = 350, RoutStore = 90, ExpStore = NULL,
                            UH1 = NULL, UH2 = NULL,
                            GCemaNeigeLayers = NULL, eTGCemaNeigeLayers = NULL,
                            verbose = TRUE) {
  
  
  ObjectClass <- NULL
  
  UH1n <- 20L
  UH2n <- UH1n * 2L
  
  
  ## check FUN_MOD
  BOOL <- FALSE
  if (identical(FUN_MOD, RunModel_GR4H)) {
    ObjectClass <- c(ObjectClass, "GR", "hourly")
    BOOL <- TRUE
  }
  if (identical(FUN_MOD, RunModel_GR4J) |
      identical(FUN_MOD, RunModel_GR5J) |
      identical(FUN_MOD, RunModel_GR6J)) {
    ObjectClass <- c(ObjectClass, "GR", "daily")
    BOOL <- TRUE
  }
  if (identical(FUN_MOD, RunModel_GR2M)) {
    ObjectClass <- c(ObjectClass, "GR", "monthly")
    BOOL <- TRUE
  }
  if (identical(FUN_MOD, RunModel_GR1A)) {
    stop("'RunModel_GR1A' does not require 'IniStates' object")
  }
  if (identical(FUN_MOD, RunModel_CemaNeige)) {
    ObjectClass <- c(ObjectClass, "CemaNeige", "daily")
    BOOL <- TRUE
  }
  if (identical(FUN_MOD, RunModel_CemaNeigeGR4J) |
      identical(FUN_MOD, RunModel_CemaNeigeGR5J) |
      identical(FUN_MOD, RunModel_CemaNeigeGR6J)) {
    ObjectClass <- c(ObjectClass, "GR", "CemaNeige", "daily")
    BOOL <- TRUE
  }
  if (!BOOL) {
    stop("Incorrect 'FUN_MOD' for use in 'CreateIniStates'")
    return(NULL)
  }
  
  ## check InputsModel
  if (!inherits(InputsModel, "InputsModel")) {
    stop("'InputsModel' must be of class 'InputsModel'")
    return(NULL)
  }
  if ("GR" %in% ObjectClass & !inherits(InputsModel, "GR")) {
    stop("'InputsModel' must be of class 'GR'")
    return(NULL)
  }
  if ("CemaNeige" %in% ObjectClass &
      !inherits(InputsModel, "CemaNeige")) {
    stop("'InputsModel' must be of class 'CemaNeige'")
    return(NULL)
  }
  
  
  ## check states
  if (any(eTGCemaNeigeLayers > 0)) {
    stop("Positive values are not allowed for 'eTGCemaNeigeLayers'")
  }  
  
  if (identical(FUN_MOD, RunModel_GR6J) | identical(FUN_MOD, RunModel_CemaNeigeGR6J)) {
    if (is.null(ExpStore)) {
      stop("'RunModel_*GR6J' need an 'ExpStore' value")
      return(NULL)
    }
  } else if (!is.null(ExpStore)) {
    if (verbose) {
      warning(sprintf("'%s' does not require 'ExpStore'. Value set to NA", as.character(substitute(FUN_MOD))))
    }
    ExpStore <- Inf
  }
  
  if (identical(FUN_MOD, RunModel_GR2M)) {
    if (!is.null(UH1)) {
      if (verbose) {
        warning(sprintf("'%s' does not require 'UH1'. Values set to NA", as.character(substitute(FUN_MOD))))
      }
      UH1 <- rep(Inf, UH1n)
    }
    if (!is.null(UH2)) {
      if (verbose) {
        warning(sprintf("'%s' does not require 'UH2'. Values set to NA", as.character(substitute(FUN_MOD))))
      }
      UH2 <- rep(Inf, UH2n)
    }
  }
  
  if ((identical(FUN_MOD, RunModel_GR5J) | identical(FUN_MOD, RunModel_CemaNeigeGR5J)) & !is.null(UH1)) {
    if (verbose) {
      warning(sprintf("'%s' does not require 'UH1'. Values set to NA", as.character(substitute(FUN_MOD))))
    }
    UH1 <- rep(Inf, UH1n)
  }
 
  if ("CemaNeige" %in% ObjectClass & ! "GR" %in% ObjectClass) {
    if (!is.null(ProdStore)) {
      if (verbose) {
        warning(sprintf("'%s' does not require 'ProdStore'. Values set to NA", as.character(substitute(FUN_MOD))))
      }
    }
    ProdStore <- Inf
    if (!is.null(RoutStore)) {
      if (verbose) {
        warning(sprintf("'%s' does not require 'RoutStore'. Values set to NA", as.character(substitute(FUN_MOD))))
      }
    }
    RoutStore <- Inf
    if (!is.null(ExpStore)) {
      if (verbose) {
        warning(sprintf("'%s' does not require 'ExpStore'. Values set to NA", as.character(substitute(FUN_MOD))))
      }
    }
    ExpStore <- Inf
    if (!is.null(UH1)) {
      if (verbose) {
        warning(sprintf("'%s' does not require 'UH1'. Values set to NA", as.character(substitute(FUN_MOD))))
      }
    }
    UH1 <- rep(Inf, UH1n)
    if (!is.null(UH2)) {
      if (verbose) {
        warning(sprintf("'%s' does not require 'UH2'. Values set to NA", as.character(substitute(FUN_MOD))))
      }
    }
    UH2 <- rep(Inf, UH2n)
  }
  if("CemaNeige" %in% ObjectClass &
     (is.null(GCemaNeigeLayers) | is.null(eTGCemaNeigeLayers))) {
    stop("'RunModel_CemaNeigeGR*' need values for 'GCemaNeigeLayers' and 'GCemaNeigeLayers'")
    return(NULL)
  }
  if(!"CemaNeige" %in% ObjectClass &
     (!is.null(GCemaNeigeLayers) | !is.null(eTGCemaNeigeLayers))) {
    if (verbose) {
      warning(sprintf("'%s' does not require 'GCemaNeigeLayers' and 'GCemaNeigeLayers'. Values set to NA", as.character(substitute(FUN_MOD))))
    }
    GCemaNeigeLayers   <- Inf
    eTGCemaNeigeLayers <- Inf
  }
  
  
  ## set states
  if("CemaNeige" %in% ObjectClass) {
    NLayers <- length(InputsModel$LayerPrecip)
  } else {
    NLayers <- 1
  }
  
  
  ## manage NULL values
  if (is.null(ExpStore)) {
    ExpStore <- Inf 
  }
  if (is.null(UH1)) {
    if ("hourly"  %in% ObjectClass) {
      k <- 24
    } else {
      k <- 1
    }
    UH1 <- rep(Inf, 20 * k)
  }
  if (is.null(UH2)) {
    if ("hourly"  %in% ObjectClass) {
      k <- 24
    } else {
      k <- 1
    }
    UH2 <- rep(Inf, 40 * k)
  }
  if (is.null(GCemaNeigeLayers)) {
    GCemaNeigeLayers <- rep(Inf, NLayers)
  }
  if (is.null(eTGCemaNeigeLayers)) {
    eTGCemaNeigeLayers <- rep(Inf, NLayers)
  }
  
  
  # check negative values
  if (any(ProdStore < 0) | any(RoutStore < 0) |
      any(UH1 < 0) | any(UH2 < 0) |
      any(GCemaNeigeLayers < 0)) {
    stop("Negative values are not allowed for any of 'ProdStore', 'RoutStore', 'UH1', 'UH2', 'GCemaNeigeLayers'")
  }
  
  
  ## check length
  if (!is.numeric(ProdStore) || length(ProdStore) != 1L) {
    print(ProdStore)
    stop("'ProdStore' must be numeric of length one")
  }
  if (!is.numeric(RoutStore) || length(RoutStore) != 1L) {
    stop("'RoutStore' must be numeric of length one")
  }
  if (!is.numeric(ExpStore) || length(ExpStore) != 1L) {
    stop("'ExpStore' must be numeric of length one")
  }
  if ( "hourly" %in% ObjectClass & (!is.numeric(UH1) || length(UH1) != 480L)) {
    stop(sprintf("'UH1' must be numeric of length 480 (%i * 24)", UH1n))
  }
  if (!"hourly" %in% ObjectClass & (!is.numeric(UH1) || length(UH1) != 20L)) {
    stop(sprintf("'UH1' must be numeric of length %i", UH1n))
  }
  if ( "hourly" %in% ObjectClass & (!is.numeric(UH2) || length(UH2) != 960L)) {
    stop(sprintf("'UH2' must be numeric of length 960 (%i * 24)", UH2n))
  }
  if (!"hourly" %in% ObjectClass & (!is.numeric(UH2) || length(UH2) != 40L)) {
    stop(sprintf("'UH2' must be numeric of length %i (2 * %i)", UH2n, UH1n))
  }
  if (!is.numeric(GCemaNeigeLayers) || length(GCemaNeigeLayers) != NLayers) {
    stop(sprintf("'GCemaNeigeLayers' must be numeric of length %i", NLayers))
  }
  if (!is.numeric(eTGCemaNeigeLayers) || length(eTGCemaNeigeLayers) != NLayers) {
    stop(sprintf("'eTGCemaNeigeLayers' must be numeric of length %i", NLayers))
  }
  

  ## format output
  IniStates <- list(Store = list(Prod = ProdStore, Rout = RoutStore, Exp = ExpStore),
                    UH = list(UH1 = UH1, UH2 = UH2),
                    CemaNeigeLayers = list(G = GCemaNeigeLayers, eTG = eTGCemaNeigeLayers))
  IniStatesNA <- unlist(IniStates)
  IniStatesNA[is.infinite(IniStatesNA)] <- NA
  IniStatesNA <- relist(IniStatesNA, skeleton = IniStates)
  
  class(IniStatesNA) <- c("IniStates", ObjectClass)
  return(IniStatesNA)
  
  
}