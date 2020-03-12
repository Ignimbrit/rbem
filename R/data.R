#' DEM tiles available for download
#' 
#' A vector-geodataset containing the positions, names and the extend of tiles of the 
#' digital elevation model of Berlin which can be accessed via this package
#' 
#' @format A \code{\link[sf:sf]{simple feature}}, a data.frame like table 
#' structure containing geographic information
#' 
#' @details 
#' EPSG: 25833
#' licence: "Geoportal Berlin / ATKRIS(R) DGM (1m-Rasterweite)" \url{https://www.govdata.de/dl-de/by-2-0}
#' 
#' @source \href{https://fbinter.stadt-berlin.de/fb/atom//Blattschnitte/2X2_EPSG_25833.gif}{Geoportal Berlin}
#' 
"dem_Index"

#' City Districts of Berlin
#' 
#' A vector-geodataset of polygons of the city districts of Berlin
#' 
#' @format A \code{\link[sf:sf]{simple feature}}, a data.frame like table 
#' structure containing geographic information
#' 
#' @details 
#' EPSG: 25833
#' licence: "Geoportal Berlin / Ortsteile" \url{https://www.govdata.de/dl-de/by-2-0}
#' 
#' @source \href{`https://fbinter.stadt-berlin.de/fb/berlin/service_intern.jsp?id=re_ortsteil@senstadt&type=WFS&themeType=spatial`}{Geoportal Berlin}
#' 
"districts"