
#' Convert target geometry to download links
#' 
#' @param x A \code{sf::st_bbox} or any object coercible to one
#' 
#' @details EPSG: 25833
#' 
#' @return a [sf][sf::`sf-package`]
#' 
bem_select_fields <- function(x){
  
  if(class(x) != "bbox") {
    x <- sf::st_bbox(x)
  }
  
  xsfc <- sf::st_as_sfc(x)
  sf::st_crs(xsfc) <- 25833
  
  dem_Index[sf::st_intersects(xsfc, dem_Index)[[1]], ]
}
