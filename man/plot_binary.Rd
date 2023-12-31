% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_binary.R
\name{plot_binary}
\alias{plot_binary}
\title{Plot Binary Survey Data}
\usage{
plot_binary(data, vars, group, weight, return_var)
}
\arguments{
\item{data}{A data frame containing survey data. This parameter is required.}

\item{vars}{A list of column names and the renamed variable. This parameter is required.}

\item{group}{A variable overlay to compare between groups. This parameter is optional.}

\item{weight}{Variable containing weight factors. This variable is optional.}

\item{return_var}{One of two variable names to return (e.g., "Yes"). This variable is required.}
}
\value{
a ggplot2 graph.
}
\description{
Utilises the function \code{binary_vars} to visualise visualise binary survey results.
}
\examples{
\dontrun{
# Create list
vars <- list(Q1a = "Art",
             Q1b = "Automobiles",
             Q1c = "Birdwatching")
plot_binary(dataset,
            vars = vars,
            group = "gender",
            weight = "wgtvar",
            return_var = "Yes")
}
}
