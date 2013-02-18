library( RCurl)
library( XML)
library( stringr)
library( doMC)

registerDoMC( cores= 4)

baseUrl <- "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs"

subDir <- "00/time_grib_01"

cfsVars <- c( "prate", "tmax", "tmin", "dswsfc")

dataPath <- "data/cfs2"

## curl <- getCurlHandle()

cfsListing <- htmlTreeParse( baseUrl, isURL= TRUE, useInternalNodes= TRUE)

cfsHrefs <- as( unlist( cfsListing[ "//@href"]), "character")
names( cfsHrefs) <- NULL

cfsMtimes <-
  strptime(
    sapply(
      unlist( cfsListing[ "//body/pre/text()"]),
      function( x) str_trim( as( x, "character"))),
    format= "%d-%b-%Y %H:%M    -")

cfsDf <- 
  data.frame( href=  cfsHrefs[ !is.na( cfsMtimes)],
             mtime= cfsMtimes[ !is.na( cfsMtimes)],
             stringsAsFactors= FALSE)

## are any of these links for the 1st or 15th day?
cfsDf <- with( cfsDf, cfsDf[ str_detect( href, "^cfs\\.[0-9]{6}(01|15)"),])


dataUrls <-
  paste(
    baseUrl, substr( cfsDf$href, 1, 12), subDir,
    sprintf( "%s.01.%s00.daily.grb2",
            cfsVars, substr( cfsDf$href, 5, 12)),
    sep= "/")

## mapply(
##   download.file,
##   dataUrls,
##   paste( dataPath, basename( dataUrls), sep="/"))


log <- foreach(
  u= dataUrls,
  d= paste( dataPath, basename( dataUrls), sep="/"),
  .combine= c) %dopar%
{
  dir.create( dirname( d), recursive= TRUE)
  if( file.exists( d) && noClobber) {
    sprintf( "%s *EXISTS*", d)
  } else {
    t <- try(
      download.file(
        url= u,
        destfile= d,
        mode= "wb",
        cacheOK= FALSE,
        quiet= FALSE),
      silent= TRUE)
    if( inherits( t, "try-error") ||  t != 0) {
      file.remove( d)
      sprintf( "%s *FAILED* %s", d, t)
    } else {
      sprintf( "%s", d)
    }
  }
}

cat( log, sep= "\n")
warnings()
