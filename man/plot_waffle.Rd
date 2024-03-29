% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_waffle.R
\name{plot_waffle}
\alias{plot_waffle}
\title{Create a Waffle Plot}
\usage{
plot_waffle(
  data,
  group,
  values = NULL,
  weight = NULL,
  isolateVar = NULL,
  orderPlots = c("none", "descending", "ascending"),
  title = NULL,
  groupColours = colour_pal("catExtended"),
  backgroundColour = colour_pal("French Grey"),
  backgroundAlpha = 0.5,
  borderColour = "white",
  borderWidth = 0.5
)
}
\arguments{
\item{data}{A data frame containing the dataset to be visualized.}

\item{group}{The column in \code{data} that contains the categorical groups for the waffle plot.}

\item{values}{Optional: The column in \code{data} that contains the numerical values used for
calculating proportions. If not provided, counts of \code{group} categories are used.}

\item{weight}{Optional: A weighting variable to be used in calculating group frequencies.}

\item{isolateVar}{Optional: A specific variable from \code{group} to isolate in the plot.}

\item{orderPlots}{Specifies how the plots should be ordered. Accepted values are 'none',
'ascending', or 'descending'. Default is 'none'.}

\item{title}{The title of the waffle plot. If the title matches the group name, the function
will return the label attribute if present.}

\item{groupColours}{A named or unnamed vector of colours for each category in the plot.}

\item{backgroundColour}{Colour for the background of the plot.}

\item{backgroundAlpha}{Alpha value (transparency) for the background.}

\item{borderColour}{Colour for the border of the tiles in the plot.}

\item{borderWidth}{Width of the border of the tiles. Default = 0.5.}
}
\value{
A \code{ggplot} object representing a waffle plot.
}
\description{
\code{plot_waffle} creates a waffle plot to visualise categorical data. This plot is useful for
showing proportions or percentages in a visually appealing and easily understandable format.
}
\examples{
  data <- data.frame(
    Category = c("A", "B", "C"),
    Count = c(30, 40, 30)
  )
  plot_waffle(data,
              group = "Category",
              values = "Count",
              title = "Sample Waffle Plot",
              orderPlots = "descending",
              groupColours = c(A = "blue", B = "yellow", C = "red"))

}
