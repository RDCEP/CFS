library( RCurl)
library( XML)
library( stringr)
library( doMC)

## registerDoMC( cores= 4)
registerDoMC( cores= multicore:::detectCores())

baseUrl <- "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs"

## subDir <- "00/time_grib_01"

date <- strftime( as.Date( "2013-02-27"), format= "%Y%m%d")

dataUrls <-
  with(
    expand.grid(
      base= baseUrl,
      date= date,
      run=  c( "01", "02", "03", "04"),
      hour= c( "00", "06", "12", "18"),
      var=  c( "prate", "tmax", "tmin", "dswsfc", "crain", "q2m", "wnd10m")),
    paste(
      base,
      sprintf( "cfs.%s", date),
      hour,
      sprintf( "time_grib_%s", run),
      sprintf(
        "%s.%s.%s%s.daily.grb2",
        var, run, date, hour), 
      sep= "/"))
  
wgetCommands <-
  paste(
    "wget", "--progress=dot:mega", ## "--no-verbose",
    "--retry-connrefused",
    "--continue",
    "--timestamping",
    "--no-host-directories",
    "--cut-dirs=7",
    "--directory-prefix=data/cfs2",
    dataUrls,
    "2>&1")

foreach(
  wgetCommand= wgetCommands) %dopar% {
    cat( system( wgetCommand, intern= TRUE), "\n", sep= "\n")
  }

## log <- foreach(
##   u= dataUrls,
##   d= paste( dataPath, basename( dataUrls), sep="/"),
##   .combine= c) %dopar%
## {
##   dir.create( dirname( d), recursive= TRUE)
##   if( file.exists( d) && noClobber) {
##     sprintf( "%s *EXISTS*", d)
##   } else {
##     t <- try(
##       download.file(
##         url= u,
##         destfile= d,
##         mode= "wb",
##         cacheOK= FALSE,
##         quiet= FALSE),
##       silent= TRUE)
##     if( inherits( t, "try-error") ||  t != 0) {
##       file.remove( d)
##       sprintf( "%s *FAILED* %s", d, t)
##     } else {
##       sprintf( "%s", d)
##     }
##   }
## }

## cat( log, sep= "\n")


warnings()
