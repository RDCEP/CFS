library( stringr, quietly= TRUE)
library( doMC, quietly= TRUE)

registerDoMC( cores= multicore:::detectCores())
## options( internet.info= 0)

noClobber <- FALSE

baseUrl <- "ftp://nomads.ncdc.noaa.gov/CFSR/HP_time_series"

cfsVars <- c( "dswsfc", "prate", "tmax", "tmin")

cfsMonths <- seq(
  from= ISOdatetime( 1979,  1, 1, 0, 0, 0, "GMT"),
  to=   ISOdatetime( 2009, 12, 1, 0, 0, 0, "GMT"),
  by= "1 month")

cfsUrlsByVar <- function( cfsVar) {
  cfsUrlFormat <- paste(
    baseUrl,
    "%Y%m",
    paste( cfsVar, "gdas", "%Y%m", "grb2", sep= "."),
    sep= "/")
  strftime( cfsMonths, tz= "GMT", format= cfsUrlFormat)
}

cfsUrls <- as.vector( sapply( cfsVars, cfsUrlsByVar))

cfsDests <- str_replace(
  string= cfsUrls,
  pattern= sprintf( "^%s", baseUrl),
  replacement= "data/cfs")

log <- foreach(
  u= cfsUrls,
  ## d= cfsDests,
  .combine= c) %dopar%
{
  ## dir.create( dirname( d), recursive= TRUE)
  ## if( file.exists( d) && noClobber) {
  ##   sprintf( "%s *EXISTS*", d)
  ## } else {
  ## t <- try(
    ## download.file(
    ##   url= u,
    ##   destfile= d,
    ##   ## mode= "wb",
    ##   method= "wget",
    ##   extra= paste(
    ##     "--retry-connrefused",
    ##     "--password=nbest@ci.uchicago.edu"),          
    ##   cacheOK= FALSE,
    ##   quiet= FALSE),
    ## silent= TRUE)
  t <- system(
    paste(
      "wget", ##  --no-verbose",
      "--retry-connrefused",
      "--continue",
      "--password=nbest@ci.uchicago.edu",
      "--timestamping",
      "--no-host-directories",
      paste(
        "--directory-prefix=data/cfs",
        str_match( u, "/([0-9]{6})/")[,2],
        sep="/"),
      u),
    intern= TRUE)
  ##   )
  ## if( inherits( t, "try-error") ||  t != 0) {
  ##   file.remove( d)
  ##   sprintf( "%s *FAILED* %s", d, t)
  ## } else {
  sprintf( "%s\n%s", u, t)
  ## }
}

cat( log, sep= "\n")
warnings()
