#' Download an SRTM V4 GeoTIFF file
#' @description Download an SRTM V4 GeoTIFF file based on lat/lon coordinates
#' @param lon a longitude supplied as decimal degrees.
#' @param lat a latitude supplied as decimal degrees.
#' @param download a choice of whether to download the file if it already exists in the specified local path.
#' @param SRTM_file_path a path for which GeoTIFF files exist locally.
#' @export download_SRTMV4_GeoTIFF

download_SRTMV4_GeoTIFF <- function(lon,
                                    lat,
                                    download = TRUE,
                                    SRTM_file_path = NULL){
  
  stopifnot(lon >= -180 & lon <= 180)
  stopifnot(lat >= -60 & lat <= 60)
  
  rs <- raster(nrows = 24, ncols = 72, xmn = -180, xmx = 180, 
               ymn = -60, ymx = 60)
  
  rowTile <- rowFromY(rs, lat)
  colTile <- colFromX(rs, lon)
  
  if (rowTile < 10) {
    rowTile <- paste("0", rowTile, sep = "")
  }
  if (colTile < 10) {
    colTile <- paste("0", colTile, sep = "")
  }
  
  # Construct filename for SRTM data
  f <- paste("srtm_", colTile, "_", rowTile, sep = "")
  
  # If a download is requested, get the file
  if (download == TRUE){
    
    temp_dir <- tempdir()
    
    zipfilename <- paste(temp_dir, "/", f, ".zip", sep = "")
    tiffilename <- paste(temp_dir, "/", f, ".tif", sep = "")
    
    download.file(url = paste("http://gis-lab.info/data/srtm-tif/", 
                              f, ".zip", sep = ""),
                  destfile = zipfilename, method = "auto", 
                  quiet = FALSE, mode = "wb", cacheOK = TRUE)
    
    if (file.exists(zipfilename)){
      unzip(zipfilename, exdir = dirname(zipfilename))
      file.remove(zipfilename)
      file.remove(gsub(".zip", ".hdr", zipfilename))
      file.remove(gsub(".zip", ".tfw", zipfilename))
      file.remove(paste(temp_dir, "/readme.txt", sep = ''))
    }
    
    if (file.exists(tiffilename)){
      rs <- raster(tiffilename)
      projection(rs) <- "+proj=longlat +datum=WGS84"
      return(rs)
    }
  }
  
  # If the file is known to exist on a supplied path, read in that file
  if (!is.null(SRTM_file_path)){
    
    zipfilename <- paste(SRTM_file_path, "/", f, ".zip", sep = "")
    tiffilename <- paste(SRTM_file_path, "/", f, ".tif", sep = "")
    
    if (!file.exists(zipfilename)){
      stop("The file doesn't exist.")
    }
    
    if (file.exists(zipfilename)){
      unzip(zipfilename, exdir = dirname(zipfilename))
      file.remove(zipfilename)
      file.remove(gsub(".zip", ".hdr", zipfilename))
      file.remove(gsub(".zip", ".tfw", zipfilename))
      file.remove(paste(SRTM_file_path, "/readme.txt", sep = ''))
    }
    
    if (file.exists(tiffilename)){
      rs <- raster(tiffilename)
      projection(rs) <- "+proj=longlat +datum=WGS84"
      return(rs)
    }
    
  }
  
}