% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/db.R
\name{get.opp.stats.by.file}
\alias{get.opp.stats.by.file}
\title{Get OPP aggregated filtered particle statistics by file.}
\usage{
get.opp.stats.by.file(db, file.name)
}
\arguments{
\item{db}{SQLite3 data file path.}

\item{file.name}{File name with julian day directory.}
}
\value{
Data frame of OPP aggregate statistics for one file.
}
\description{
Requires a populated sfl table.
}
\examples{
\dontrun{
opp.stats <- get.opp.stats.by.file(db, "2014_185/2014-07-04T00-00-02+00-00")
}
}
