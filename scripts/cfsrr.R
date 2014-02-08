library( stringr, quietly= TRUE)
library( doMC, quietly= TRUE)
library( lubridate)

registerDoMC( cores= 4)
registerDoMC( cores= multicore:::detectCores())
## options( internet.info= 0)


## noClobber currently has no effect

## TODO: implement forced overwrite for if( noClobber)

noClobber <- TRUE

baseUrl <- "http://nomads.ncdc.noaa.gov/modeldata/cmd_ts_9mon"

cfsVars <- c( "dswsfc", "prate", "tmax", "tmin", "wnd10m")

## CFS archive does not account for leap days, so the sequence is
## somewhat irregular

## everyThirtyJulianDaysNoLeapDays <- function( year) {
##   interval <- c(
##     1, 30,
##     ifelse( leap_year( year), 31, 30),
##     rep( 30, times= 9))
##   days <- cumsum( interval)
##   dates <- as.POSIXct( paste( year, days), format= "%Y %j", tz= "GMT")
##   names( dates) <- sprintf( "%4d.%02d", year, days %/% 30 + 1)
##   dates
## }

everyFiveJulianDaysNoLeapDays <- function( year) {
  interval <- c(
    1, rep( 5, times= 11),
    ifelse( leap_year( year), 6, 5),
    rep( 5, times= 365/5 -13))
  days <- cumsum( interval)
  dates <- as.POSIXct( paste( year, days), format= "%Y %j", tz= "GMT")
  names( dates) <- sprintf( "%4d.%02d", year, days)
  dates
}

cfsDates <- foreach(
  year= 1981:2011,
  .combine= c) %do% {
    everyFiveJulianDaysNoLeapDays( year)
  }

cfsDates <-
  cfsDates[  cfsDates >= ISOdatetime( 1981,  12, 12, 0, 0, 0, "GMT")
           & cfsDates <= ISOdatetime( 2011,   3, 27, 0, 0, 0, "GMT")]

writeCfsUrls <- function( cfsVar, cfsDate, md5= FALSE) {
  cfsUrlFormat <- paste(
    baseUrl,
    "%Y", "%Y%m",
    paste( cfsVar, "%Y%m%d%H", "time", "grb2", sep= "."),
    sep= "/")
  cfsFileUrl <- strftime(
    cfsDate, tz= "GMT",
    format= cfsUrlFormat)
  if( md5) {
    paste( cfsFileUrl, "md5", sep= ".")
  } else {
    cfsFileUrl
  }
}


cfsUrls <-
  foreach( cfsVar= cfsVars,
          .combine= c) %:%
  foreach( cfsDate= cfsDates,
          .combine= c) %dopar% {
    writeCfsUrls( cfsVar, cfsDate)}

## cfsMd5Urls <-
##   foreach( cfsVar= cfsVars,
##           .combine= c) %:%
##   foreach( cfsDate= cfsDates,
##           .combine= c) %dopar% {
##     writeCfsUrls( cfsVar, cfsDate, md5= TRUE)}

## cfsUrlNames <-
##   foreach( cfsVar= cfsVars) %do% {
##     paste( cfsVar, names( cfsDates), sep= ".")
##   }

## names( cfsUrls) <- cfsUrlNames

cfsWgetCommands <-
  paste(
    "wget",
    "--progress=dot:mega",
    "--retry-connrefused",
    "--waitretry=20",
    "--tries=20",
    "--timestamping",
    "--no-host-directories",
    paste(
      "--directory-prefix=data/cfsrr",
      str_match( cfsUrls, "/([^/.]+)\\.[0-9]{10}\\.time.grb2$")[,2],
      sep="/"),
    cfsUrls,
    "2>&1")

## cfsWgetCommands <- c(
##     writeCfsWgetCommands( cfsUrls),
##     writeCfsWgetCommands( cfsMd5Urls))

  
## cfsWgetOutput <-
##   foreach(
##     cfsWgetCommand= writeCfsWgetCommands( head( cfsUrls))) %dopar% {
##       system( cfsWgetCommand, intern= TRUE)
##   }

## cfsWgetOutput <-
##   foreach(
##     cfsWgetCommand= writeCfsWgetCommands( cfsUrls)) %dopar% {
##       system( cfsWgetCommand, intern= TRUE)
##   }

## cat(
##   unlist( cfsWgetOutput),
##   "\n",
##   "Summary:",
##   sapply(
##     cfsWgetOutput,
##     function( wgetOutput) {
##       wgetOutput[ length( wgetOutput) -1]}),
##   sep= "\n")

repeat {
  cfsWgetOutput <- 
    foreach(
      cfsWgetCommand= cfsWgetCommands) %dopar% {
        Sys.sleep( 3 * ( runif( 1) + 0.5))
        system( cfsWgetCommand, intern= TRUE)
      }
  cfsWgetSummary <-
    sapply(
      cfsWgetOutput,
      function( wgetOutput) {
        wgetOutput[ length( wgetOutput) -1]})
  names( cfsWgetSummary) <- cfsUrls
  cfsWgetErrors <-
    length( which( str_detect( cfsWgetSummary, "ERROR (503|404)")))
  cat(
    unlist( cfsWgetOutput),
    "\n",
    "Summary:",
    "\n",
    cfsWgetSummary,
    "\n",
    paste(
      "503 or 404 Errors:",
      cfsWgetErrors,
      ". . .",
      ifelse(
        cfsWgetErrors,
        "retrying.",
        "done.")),
    sep= "\n")
  if( !cfsWgetErrors) break
  ## break
}


## TODO: check the MD5 sums in the course of downloading and retry on
## checksum failure

## TODO: create symlinks to name by pseudo-months
