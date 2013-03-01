library( RCurl)
library( XML)
library( stringr)
library( doMC)

## registerDoMC( cores= 4)
registerDoMC( cores= multicore:::detectCores())

baseUrl <- "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs"

## subDir <- "00/time_grib_01"

cfsDates <-
  seq(
    from= Sys.Date() -1,
    by= "-1 day",
    length.out= 6)

strftime( cfsDates, format= "cfs.%Y%m%d")

dataUrls <-
  with(
    expand.grid(
      base= baseUrl,
      date= cfsDates,
      run=  c( "01", "02", "03", "04"),
      hour= c( "00", "06", "12", "18"),
      var=  c(
        "prate", "tmax", "tmin", "dswsfc",
        "crain", "q2m", "wnd10m")),
    paste(
      base,
      strftime( date, format= "cfs.%Y%m%d"),
      hour,
      sprintf( "time_grib_%s", run),
      paste(
        var, run,
        paste(
          strftime(
            date,
            format= "%Y%m%d"),
          sprintf( "%s.daily.grb2", hour),
          sep= ""),
        sep= "."), 
      sep= "/"))
  
wgetCommands <-
  paste(
    "wget",
    "--recursive",
    "--progress=dot:mega",
    ## "--no-verbose",
    "--retry-connrefused",
    "--continue",
    "--timestamping",
    "--no-host-directories",
    "--cut-dirs=7",
    dataUrls,
    "2>&1")

oldWd <- setwd( "data/cfs2")

log <-
  foreach(
    wgetCommand= wgetCommands,
    .combine= c) %dopar% {
      c( system( wgetCommand, intern= TRUE), "\n")
    }


cat(
  log,
  warnings(),
  sep= "\n")

setwd( oldWd)
