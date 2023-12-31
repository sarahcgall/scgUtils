% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grp_mean.R
\name{grp_mean}
\alias{grp_mean}
\title{Grouped Mean}
\usage{
grp_mean(data, var, group, weight, set_names, round_decimals = NULL)
}
\arguments{
\item{data}{A data frame containing survey data. This parameter is required.}

\item{var}{Variable to be averaged. var must be numeric. This parameter is required.}

\item{group}{Variable being grouped. This parameter is required.}

\item{weight}{Variable containing weight factors. This variable is optional.}

\item{set_names}{Vector of column names. This paramenter is optional.}

\item{round_decimals}{Numeric value to round numeric data by x number of decimals places. Default does not round.}
}
\value{
A data frame containing averages by group
}
\description{
Calculates the mean of a variable by a group in survey data.
}
\examples{
\dontrun{
# Return a averages of a variable by group (weighted or unweighted)
tmp <- grp_mean(dataset,
               var = "age",
               group = "gender",
               weight = "wgtvar")

#   gender     Mean
# 1   Male 42.78670
# 2 Female 41.06441

# NB for non-grouped averages, use mean(var) or weighted.mean(var, weight)
}
}
