#' Specify a rectangular target area for dem data
#' 
#' @param xmin The left boundary of the target rectangle
#' @param xmax The right boundary of the target rectangle
#' @param ymin The lower boundary of the target rectangle
#' @param ymax The upper boundary of the target rectangle
#' 
#' @details EPSG: 25833
#' 
#' @return A \code{\link[sf:st_bbox]{Bounding Box}}
#' 
#' @export
#' 
#' @examples
#' bem_target(
#' xmin = 384000, 
#' xmax = 386000, 
#' ymin = 5806000, 
#' ymax = 5808000)
#'  
bem_target <- function(
  xmin,
  xmax,
  ymin,
  ymax
) {
  if(
    !all(
      vapply(
        X = c(xmin, xmax, ymin, ymax), FUN = is.numeric, FUN.VALUE = TRUE
      )
    )
  ) {
    stop("Input mus be coercible to numeric")
  }
  
  sf::st_bbox(
    sf::st_multipoint(matrix(c(xmin, xmax, ymin, ymax), 2))
  )
}


#' Download and load digital elevation data of Berlin
#' 
#' @param x The target area for which dem data are to be downloaded.
#' Either created with \code{bem_target} or any object which can be 
#' passed to \code{sf::st_bbox}
#' 
#' @param directory A string giving the path to the directory where downloaded 
#' .zip files should be saved to
#' 
#' @param read Logical. Should the downloaded data be read into R?
#' 
#' @param output_format Character specifying the output format.
#' Default "raster" will return output as \code{raster::`Raster-class`}.
#'  The alternative is "tbl" which will return a 
#'  \code{tibble::`tibble-package`} of xyz coordinates instead.
#'  
#' @param merge_output Logical. If \code{TRUE}, all downloaded tiles will be 
#' merged in a single object. If \code{FALSE}, a list of objects with one entry
#' per tile will be returned
#' 
#' @details This function will identify targeted tiles of the 1m resolution 
#' digital elevation model of Berlin that are distributed by the
#' \href{https://fbinter.stadt-berlin.de/fb/atom//Blattschnitte/2X2_EPSG_25833.gif}{Geoportal Berlin}
#' ("Geoportal Berlin / ATKRIS(R) DGM (1m-Rasterweite)" \url{https://www.govdata.de/dl-de/by-2-0})
#' and download them into a specified directory (default is "BEMdata/"). It
#' will then attempt to load all downloaded data into R and return it in a 
#' meaningful format that should make further processing easy.
#' 
#' @return Either a \code{raster::`Raster-class`}, a 
#' \code{tibble::`tibble-package`} or a \code{list} of any of those things,
#' depending on \code{output_format}. If \code{read = FALSE}, \code{x} 
#' is returned invisible.
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' my_area_of_interest <- bem_target(
#' xmin = 384000, 
#' xmax = 386000, 
#' ymin = 5806000, 
#' ymax = 5808000)
#' 
#' # Careful! This will kick of ~ 100 MB download!
#' result <- bem_data(my_area_of_interest)
#' 
#' # In this case the result can be examined e.g. with the help of
#' 
#' # raster::plot(result)
#'
#' # or
#' 
#' # mapview::mapview(result)
#'      
#' }
#'   
#'   
#' 
bem_data <- function(
  x, 
  directory = "BEMdata", 
  read = TRUE,
  output_format = "raster",
  merge_output = TRUE
){
  
  `%notin%` <- Negate(`%in%`)
  if(output_format %notin% c("raster", "tbl")){
    stop("output_format must either be 'raster' or 'tbl'")
  }

  fields <- suppressWarnings(bem_select_fields(x))
  
  if(!dir.exists(directory)){
    dir.create(directory)
  }
  
  zipnames <- fields[["name"]]
  links <- purrr::map_chr(
    zipnames,
    function(x){paste0("http://fbinter.stadt-berlin.de/fb/atom/DGM1/", x)}
  )
  
  catcher <- vector("list", length = length(links))
  for(i in seq_along(links)){
    download.file(
      links[i], 
      destfile = paste0(directory, "/", zipnames[i])
    )
    
    if(read == TRUE) {
      faketempdirname <- paste0(directory, "/faketempdir")
      
      unzip(
        zipfile = paste0(directory, "/", zipnames[i]),
        exdir = faketempdirname
      )
      
      xyz_file <- list.files(paste0(faketempdirname, "/"), pattern = ".txt$")[1]
      
      xyz_data <- readr::read_delim(
        paste0(faketempdirname, "/", xyz_file),
        col_names = FALSE,
        delim = " ",
        col_types = list(readr::col_double(), readr::col_double(), readr::col_double())
      )
      names(xyz_data) <- c("x", "y", "z")
      
      unlink(faketempdirname, recursive = TRUE)
      
      catcher[[i]] <- xyz_data
    } else {
      return(invisible(x))
    }
  }
  
  if(output_format == "tbl"){
    if(merge_output == TRUE) {
      dplyr::bind_rows(catcher)
    } else {
      catcher
    }
  } else if(output_format == "raster"){
    rasterlist <- purrr::map(
      catcher,
      raster::rasterFromXYZ,
      res = c(1, 1),
      crs = raster::crs(as(dem_Index, "Spatial")),
      digits = 3
    )
    
    if(merge_output == TRUE){
      do.call(raster::merge, rasterlist)
    } else {
      rasterlist
    }
  } else {
    stop("output_format must either be 'raster' or 'tbl'")
  }
}

