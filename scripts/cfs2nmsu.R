library( doMC)

registerDoMC( cores= 4)
## registerDoMC( cores= multicore:::detectCores())

baseUrl <- "http://cirrus.nmsu.edu:8080/thredds/fileServer/cfs"

cfsDates <-
  seq(
    from= as.Date( "2013-02-22"),
    to= as.Date( "2011-09-17"),
    by= "-1 day")

dataUrls <-
  with(
    expand.grid(
      base= baseUrl,
      date= cfsDates,
      run=  "01", ## c( "01", "02", "03", "04"),
      hour= "00", ## c( "00", "06", "12", "18"),
      var=  c(
        "prate", "tmax", "tmin", "dswsfc",
        ## "crain",
        "q2m", "wnd10m")),
    paste(
      base,
      strftime( date, format= "cfs.%Y%m%d"),
      ## hour,
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
    ## "--continue",
    "--timestamping",
    "--no-host-directories",
    "--cut-dirs=3",
    dataUrls,
    "2>&1")

oldWd <- setwd( "data/cirrus.nmsu.edu")

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
