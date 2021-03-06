# Extra functions

#' Dimension code
#'
#' @return A vector with \code{c("spatial", "temporal")}
DimeCode <- function(){return(c("spatial", "temporal"))}


#' Dimension
#'
#' @return A vector with \code{c("Spatial", "Temporal")}
Dimension <- function(){return(c("Spatial", "Temporal"))}

#' Red white blue palette
#'
#' @return A palette function
palRWB <- function(){return(colorNumeric(c("blue","white", "red"), c(0,1), na.color = "transparent"))}

#' Green white red palette
#'
#' @return A palette function
palGWR <- function(){return(colorNumeric(c("red","lightpink", "green4"), c(0,1), na.color = "transparent"))}

#' Time resolution codes
#'
#' @return A vector with \code{c("", "yearly", "month","monthly", "daily")}
TimeResCode<-function(){return(c("none","yearly", "month","monthly", "daily"))}
# TimeResCode<-function(){return(c("yearly", "month","monthly", "daily"))}

#' Time resolution
#'
#' @return A vector with \code{c("NULL", "Yearly", "Month","Monthly", "Daily")}
TimeRes<-function(){return(c("NONE", "Yearly", "Month","Monthly", "Daily"))}
# TimeRes<-function(){return(c("Yearly", "Month","Monthly", "Daily"))}

#' Variable codes
#'
#' @return A vector with \code{c("nObs", "nVis", "nSpp", "avgSll", "nYears", "nDays", "nCells")}
VarCode<-function(){return(c("nObs", "nVis", "nSpp", "avgSll", "nYears", "nDays", "nCells"))}

#' Variables
#'
#' @return A vector with variables
Variable<-function(){return(c("n. Observations", "n. Visits", "n. Species", 
                              "avg. Species List Length", "n. Years", "n. Days", 
                              "n. Gridcells"))}

#' Method code
#'
#' @return A vector with \code{c("sum", "median", "mean")}
MethCode<-function(){return(c("sum", "median", "mean"))}

#' Method
#'
#' @return A vector with \code{c("Sum", "Median", "Mean")}
Method<-function(){return(c("Sum", "Median", "Mean"))}



#' Create tooltip
#'
#' @param text Text to show
#' @param tip Tip to show
#'
#' @return an HTML string for class bubble
#' @export
tooltipHTML <- function(text, tip){
  shiny::HTML(paste0('<span class="bubble">', text, '
            <span>' ,
              tip,
            '</span>                                                             
           </span>'))
}

#' Clean coordinates
#'
#' @param x data
#' @param lon longitude
#' @param lat latitude
#' @param species species name
#'
#' @return list of cleaned coordinates
#' @export
cleanCoordinates <- function(x,
                             lon="decimallongitude",
                             lat="decimallatitude",
                             species="scientificname"){
  logs<-""
  print("Running data cleaning module")
  
  if ("countryCode" %in% colnames(x)){
    x$countryCode <- ISOcodes::ISO_3166_1$Alpha_3[match(x$countryCode, ISOcodes::ISO_3166_1$Alpha_2)]   
  } else {
    x$countryCode <- NA
  }
  
    
  #Run coordinate cleaner
  try(sp.data.clean <- CoordinateCleaner::clean_coordinates(x,
                                                            lon=lon,
                                                            lat=lat,
                                                            species=species,
                                                            countries = "countryCode",
                                                            value="clean",
                                                            tests=c("countries","capitals","centroids", "equal", "gbif",
                                                                    "institutions", "outliers", "seas","zeros")))
  if(exists("sp.data.clean")){
    x <- sp.data.clean
    logs <- paste(logs, nrow(x), "records remain after running CoordinateCleaner\n")
  } else {
    logs <- paste(logs, "CoordinateCleaner failed. Trying now without country test\n")
    tryCatch({sp.data.clean <- CoordinateCleaner::clean_coordinates(x,
                                                                    lon=lon,
                                                                    lat=lat,
                                                                    species=species,
                                                                    countries = NULL,
                                                                    value="clean",
                                                                    tests=c("capitals","centroids", "equal", "gbif",
                                                                            "institutions", "seas","zeros"))
    x <- sp.data.clean
    logs <- paste(logs, nrow(x), "records remain after running CoordinateCleaner\n")},
    error = function(e) {
      logs <- paste(logs, e)
      logs <- paste(logs, "CoordinateCleaner failed. No data cleaning performed.\n")
    })
  }
  return(list(x, logs))
}

#' Escape HTML entities
#'
#' Escape HTML entities contained in a character vector so that it can be safely
#' included as text or an attribute value within an HTML document
#' Copied from htmlTools v 0.5.1.1 
#' @source htmlTools v 0.5.1.1 
#'
#' @param text Text to escape
#' @param attribute Escape for use as an attribute value
#'
#' @return Character vector with escaped text.
#'
#' @export
htmlEscape <- local({
  
  .htmlSpecials <- list(
    `&` = '&amp;',
    `<` = '&lt;',
    `>` = '&gt;'
  )
  .htmlSpecialsPattern <- paste(names(.htmlSpecials), collapse='|')
  .htmlSpecialsAttrib <- c(
    .htmlSpecials,
    `'` = '&#39;',
    `"` = '&quot;',
    `\r` = '&#13;',
    `\n` = '&#10;'
  )
  .htmlSpecialsPatternAttrib <- paste(names(.htmlSpecialsAttrib), collapse='|')
  
  function(text, attribute=FALSE) {
    pattern <- if(attribute)
      .htmlSpecialsPatternAttrib
    else
      .htmlSpecialsPattern
    
    text <- enc2utf8(as.character(text))
    # Short circuit in the common case that there's nothing to escape
    if (!any(grepl(pattern, text, useBytes = TRUE)))
      return(text)
    
    specials <- if(attribute)
      .htmlSpecialsAttrib
    else
      .htmlSpecials
    
    for (chr in names(specials)) {
      text <- gsub(chr, specials[[chr]], text, fixed = TRUE, useBytes = TRUE)
    }
    Encoding(text) <- "UTF-8"
    
    return(text)
  }
})