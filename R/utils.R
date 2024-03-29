#' Check Parameters for Various Functions
#'
#' This utility function performs checks on parameters for a variety of functions
#' within the package. It ensures that inputs conform to expected types and
#' values, specifically focusing on data frames and their columns.
#'
#' @param data A data frame that is checked for validity as the primary data source.
#' @param ... Additional parameters to be checked, typically representing columns
#'   in the `data` data frame. These are validated for their presence in `data`.
#' @param vars An optional list of variables to check within the data frame.
#'   Each element of the list should be named and correspond to a column in `data`.
#' @param groups An optional vector specifying group names to be checked against
#'   columns in `data`.
#' @param groupsPercent An optional vector specifying percentage groups that
#'   must be a subset of the groups specified in `groups`.
#'
#' @details
#' The function primarily checks the following:
#'   - `data` is a valid data frame.
#'   - Variables specified in `...`, `vars`, `groups`, and `groupsPercent` are
#'     present as columns in `data`.
#'   - `vars` is a non-empty named list if provided.
#'   - `groupsPercent` is a subset of `groups` if both are provided.
#'   - Specific checks for the presence and type of the `weight` and `meanVar`
#'     columns if they are specified.
#'
#' @return This function does not return a value but stops with an error message
#'   if any check fails.
#'
#' @note This function is used by `crosstab`, `grid_vars`, `grp_freq`, `grp_mean`,
#'   `plot_bigfive`, `plot_binary`, `plot_popn`, `plot_sankey`, and `process_factors`.
#'
#' @noRd
check_params <- function(data, ..., vars = NULL, groups = NULL, groupsPercent = NULL) {
  # Check for common mandatory parameters
  if (!is.data.frame(data)) {
    stop("Parameter `data` is required and must be a data frame.")
  }

  # Function to check if a variable is in the data frame
  check_in_data <- function(name, value, data) {
    if (!all(value %in% names(data))) {
      stop(paste0("`", name, "` must be a column in `data`."))
    }
  }

  # Check optional and less common mandatory parameters
  params <- list(...)
  for (name in names(params)) {
    value <- params[[name]]

    if (!is.null(value)) {
      check_in_data(name, value, data)
      if (name %in% c("weight", "meanVar", "seatCol", "percentCol", "values") && !is.numeric(data[[value]])) {
        stop(paste0("`", name, "` must be numeric."))
      }
    }
  }

  # Special check for vars (list) and groups (vector)
  if (!missing(vars) && !is.null(vars)) {
    if (is.list(vars) && is.null(names(vars))) {
      stop("`vars` must be a non-empty list with named elements.")
    } else if (!is.list(vars)) {
      check_in_data("vars", vars, data)
    } else {
      check_in_data("vars", names(vars), data)
    }
  }

  if (!missing(groups) && !is.null(groups)) {
    check_in_data("groups", groups, data)
  }

  if (!missing(groupsPercent) && !is.null(groupsPercent)) {
    check_in_data("groupsPercent", groupsPercent, data)
    if (!all(groupsPercent %in% groups)) {
      stop("`groupsPercent` variable must be in `groups`.")
    }
  }
}

#' Round Numeric Variables in Data Frame
#'
#' @description
#' This function rounds all numeric variables in a given data frame to a
#' specified number of decimal places, provided that the `decimals` parameter is numeric.
#'
#' @param data A data frame containing the numeric variables to be rounded.
#' @param decimals An integer specifying the number of decimal places to which
#'   the numeric variables should be rounded.
#'
#' @return Returns a data frame with all numeric variables rounded to the
#'   specified number of decimal places if `decimals` is numeric. Non-numeric variables
#'   in the data frame are not modified.
#'
#' @details
#' The function checks if the `decimals` parameter is numeric. If so, it identifies
#' all numeric columns in the provided data frame and rounds these columns to the
#' specified number of decimal places. This operation is applied to each numeric column
#' in the data frame. If `decimals` is not numeric, the function returns the data
#' without modifications.
#'
#' @note This function is used by `crosstab`, `grp_freq`, and `grp_mean`.
#'
#' @noRd
round_vars <- function(data, decimals) {
  if (is.numeric(decimals)) {
    numeric_cols <- sapply(data, is.numeric)
    data[, numeric_cols] <- round(data[, numeric_cols], digits = decimals)
  }
  return(data)
}

#' Pivot Data from Long to Wide Format
#'
#' This function transforms data from a long format to a wide format, similar
#' to the functionality provided by `tidyr::pivot_wider()`. It rearranges data
#' based on specified variables, creating a wider representation.
#'
#' @param data A data frame in long format that needs to be transformed into
#'   a wide format.
#' @param vars A character vector specifying the variables to use for pivoting.
#'   The first element is used as the identifier variable, and the remaining
#'   elements specify the variables to be spread out.
#'
#' @details
#' The function uses `stats::xtabs` to create a contingency table, spreading
#' the specified `vars` across the columns. It then adjusts the data frame
#' structure to achieve a wide format. The first variable in `vars` is used as
#' the identifier column.
#'
#' @return Returns a data frame in wide format with the first variable in `vars`
#'   as the identifier and other variables spread as columns.
#'
#' @note This function is used by `crosstab`.
#'
#' @importFrom stats reformulate
#' @importFrom stats xtabs
#' @noRd
pivot_wide <- function(data, vars) {
  formula <- stats::reformulate(vars, response = "Freq")
  tmp <- as.data.frame.matrix(stats::xtabs(formula, data), stringsAsFactors = TRUE)

  # Make rownames first column
  tmp <- cbind(rownames(tmp), tmp)

  # Remove index/row names
  rownames(tmp) <- NULL

  # Rename
  names(tmp)[names(tmp) == "rownames(tmp)"] <- vars[1]

  # Return original factor levels
  tmp[, vars[1]] <- factor(tmp[, vars[1]], levels(data[, vars[1]]))

  return(tmp)
}

#' Append Arguments to a Vector
#'
#' This function takes a variable number of arguments and appends them to a
#' vector. If arguments are provided, they are concatenated into a single vector.
#' If no arguments are provided, the function returns `NULL`.
#'
#' @param ... A variable number of arguments.
#'
#' @details
#' The function uses `c(...)` to concatenate all provided arguments into a
#' single vector. If no arguments are provided, the function returns `NULL`.
#' This is useful for dynamically building vectors based on conditional
#' inclusion of elements.
#'
#' @return Returns a concatenated vector of all input arguments if any are
#'   provided. Returns `NULL` if no arguments are provided.
#'
#' @note This function is used by `grid_vars`.
#'
#' @noRd
append_if_exists <- function(...) {
  elements <- c(...)
  if (length(elements) > 0) {
    return(unlist(elements))
  } else {
    return(NULL)
  }
}

#' Create a List of Columns Based on Specified Group
#'
#' This function takes a data frame and a group of column names, and creates a
#' list where each element corresponds to one of the specified columns.
#'
#' @param data A data frame from which columns are selected.
#' @param group A vector of column names to be included in the list.
#'
#' @details
#' The function iterates over the names in `group`, extracts the corresponding
#' column from `data`, and adds it to a list. Each list element is named after
#' the column it represents.
#'
#' @return Returns a list where each element is a column from `data` as specified
#'   in `group`. The names of the list elements correspond to the column names.
#'
#' @note This function is used by `grp_freq` and `grp_mean`.
#'
#' @noRd
list_group <- function(data, group) {
  grp <- list()
  for (x in group) {
    y <- data[, x]
    grp[[x]] <- y
  }
  return(grp)
}

#' Calculate Percentages of Vector Elements
#'
#' @description
#' The `percent` function computes the percentage representation of each element in a numeric vector
#' relative to the total sum of all elements in the vector.
#'
#' @param x A numeric vector for which percentages are to be calculated.
#'
#' @return A numeric vector where each element represents the percentage of the corresponding
#'   element in `x` relative to the total sum of `x`.
#'
#' @details
#' The function divides each element of `x` by the total sum of `x` and then multiplies by 100 to
#' convert the proportions into percentages. This is particularly useful for converting count data into
#' percentage representations.
#'
#' @note This function is used by functions such as `compile` and `grp_freq` within the package.
#'
#' @noRd
percent <- function(x) {
  x / sum(x) * 100
}

#' Calculate Proportions of Vector Elements
#'
#' @description
#' The `proportion` function computes the proportional representation of each element in a numeric vector
#' relative to the total sum of all elements in the vector.
#'
#' @param x A numeric vector for which proportions are to be calculated.
#'
#' @return A numeric vector where each element represents the proportion of the corresponding
#'   element in `x` relative to the total sum of `x`.
#'
#' @details
#' The function divides each element of `x` by the total sum of `x`, providing a proportional
#' representation of each element. This is useful for expressing count data as proportions of the total.
#'
#' @note This function is used by functions such as `compile` and `grp_freq` within the package.
#'
#' @noRd
proportion <- function(x) {
  x / sum(x)
}

#' Set Column Names for Data Frame
#'
#' This internal helper function sets the column names for a
#' data frame based on specified groups or provided names. It also accounts for
#' an optional 'Perc' column and allows for a default column name.
#'
#' @param data The data frame whose column names are to be set.
#' @param groups The names of the groups used in the data frame.
#' @param set_names Optional custom names for the columns.
#' @param default_col_name The default name for the main frequency column if
#'   `set_names` is not provided (default is "Freq").
#'
#' @return A data frame with updated column names.
#'
#' @details
#' If `set_names` is provided, the data frame's column names are set to these values.
#' Otherwise, the column names are set to the group names followed by the value of
#' `default_col_name`. If the "Perc" column exists in `data`, it is included in
#' the column names after `default_col_name`.
#'
#' This function is designed to be versatile and is used by various functions
#' within the package, allowing for different default column names depending on
#' the context.
#'
#' @note This function is used by functions such as `grp_mean` and `grp_freq` within the package.
#'
#' @noRd
set_column_names <- function(data,
                             groups,
                             set_names,
                             default_col_name = "Freq"
) {
  # If user provides set_names, use them
  if (!is.null(set_names)) {
    data <- stats::setNames(data, set_names)
  } else {
    # Construct default column names
    default_names <- c(groups, default_col_name)

    # Include 'Perc' if it exists in the data
    if ("Perc" %in% names(data)) {
      default_names <- c(default_names, "Perc")
    }

    data <- stats::setNames(data, default_names)
  }
  return(data)
}

#' Create Radar Chart Coordinates
#'
#' This function sets up the coordinate system for radar charts using ggplot2's
#' polar coordinates. It is a custom coordinate function designed to work
#' seamlessly with ggplot2.
#'
#' @param theta The variable to map onto the angle in the plot.
#'   Can be either "x" or "y".
#' @param start The starting position of the first radar axis in radians,
#'   with 0 being at the top.
#' @param direction The direction in which the radar axes are drawn.
#'   1 for counterclockwise and -1 for clockwise.
#'
#' @details
#' `coord_radar` extends ggplot2's `CoordPolar` to create radar charts. The
#' function allows customization of the radar chart's orientation and direction.
#' It maps the specified `theta` variable onto the angular axes of the plot,
#' and the other variable (either `x` or `y`, whichever is not `theta`) onto
#' the radial axes.
#'
#' @return Returns a ggproto object representing the coordinate system for a
#'   radar chart.
#'
#' @note This function is used by `plot_bigfive`.
#'
#' @importFrom ggplot2 ggproto
#' @importFrom ggplot2 CoordPolar
#' @noRd
coord_radar <- function(theta = "x", start = 0, direction = 1) {
  theta <- match.arg(theta, c("x", "y"))
  ggplot2::ggproto("CoordRadar", ggplot2::CoordPolar,
                   theta = theta,
                   r = ifelse(theta == 'x', 'y', 'x'),
                   start = start,
                   direction = sign(direction),
                   is_linear = function(coord) TRUE,
                   clip = "off")
}

#' Convert Selected Group Values to Negative in a Data Frame
#'
#' This function multiplies the values in a specified column by -1 for rows where
#' a specified condition based on another column is met. It is typically used
#' for adjusting data for plotting purposes, such as making one group's values
#' negative to distinguish them in a plot.
#'
#' @param data A data frame containing the data to be modified.
#' @param idCol The name of the column in `data` used to check the condition.
#' @param idVal The value in the `idCol` column that determines which rows are
#'   affected. Rows with this value in `idCol` will have their `column` values
#'   converted to negative.
#' @param percCol The name of the column in `data` whose values will be
#'   multiplied by -1 if the condition is met.
#'
#' @details
#' The function identifies rows in `data` where `xVar` equals `value` and
#' multiplies the corresponding values in `column` by -1. This is useful in
#' scenarios such as preparing data for plotting, where negative values might be
#' used for visual distinction.
#'
#' @return Returns the modified data frame with selected values in `column`
#'   converted to negative based on the condition in `xVar`.
#'
#' @note This function is used by `plot_popn` and `plot_likert`.
#'
#' @noRd
convert_neg <- function(data,
                        idCol,
                        idVal,
                        idNeu = NULL,
                        percCol
) {
  # Convert 'left' values to negative
  data[data[idCol] == idVal, percCol] <- data[data[idCol] == idVal, percCol] * -1

  # Convert half of neutrals if not idNeu is not NULL
  if (!is.null(idNeu)) {
    # Get indices of neutral responses
    neutral_indices <- which(data[[idCol]] == idNeu)

    # Divide 'percCol' by 2 for neutral responses
    data[neutral_indices, percCol] <- data[neutral_indices, percCol] / 2

    # Duplicate neutral responses
    neutral_dupes <- data[neutral_indices,]

    # Make 'Perc' negative for duplicates
    neutral_dupes[[percCol]] <- -neutral_dupes[[percCol]]

    # Bind duplicates back to original data
    data <- rbind(data, neutral_dupes)
  }

  return(data)
}


reverse_negatives <- function(data, factor_col, value_col) {
  # Split the data into two subsets
  negatives <- data[data[[value_col]] < 0, ]
  positives <- data[data[[value_col]] >= 0, ]

  # Drop unused levels for both subsets
  negatives[[factor_col]] <- factor(negatives[[factor_col]])
  positives[[factor_col]] <- factor(positives[[factor_col]])

   # Reverse the factor levels for the negative subset
  negatives[[factor_col]] <- factor(negatives[[factor_col]], levels = rev(levels(negatives[[factor_col]])))

  # Merge the two subsets back together
  data <- rbind(negatives, positives)

  # Return the reordered data
  return(data)
}

#' Evaluate Contrast of Colour List for Text Legibility
#'
#' This function assesses the brightness of each colour in a provided list and
#' determines whether the contrast is suitable for use with text. It's based on
#' the concept that colours with lower brightness are more suitable for text on
#' light backgrounds and vice versa.
#'
#' @param colour_list A list of colour values (in hexadecimal or named colours)
#'   to be tested for text contrast.
#'
#' @details
#' The function converts each colour in `colour_list` to its RGB values, then
#' applies a formula to determine its brightness. The formula considers standard
#' weights for the red, green, and blue components of the colour. A brightness
#' threshold is used to classify whether the colour is suitable for text contrast
#' (true if suitable for dark text on light background, false otherwise).
#'
#' @return Returns a data frame with a boolean column `contrast`. Each row
#'   corresponds to a color from `colour_list`, indicating whether it meets the
#'   contrast threshold for text legibility.
#'
#' @note This function is used by `colour_display`.
#'
#' @importFrom grDevices col2rgb
#' @noRd
contrast_test <- function(colour_list) {
  contrasts <- sapply(colour_list, function(x) {
    brightness <- (sum(grDevices::col2rgb(x) * c(299, 587, 114)) / 1000)
    ifelse(brightness < 186, "white", colour_pal("Black96"))
  })
  names(contrasts) <- names(colour_list)
  return(contrasts)
}

#' Convert Colour Names to Hexadecimal Codes
#'
#' This utility function converts a list or vector of colour names to their corresponding hexadecimal codes.
#' It handles both named colours and already specified hexadecimal codes.
#'
#' @param colours A list or vector of colour names or hexadecimal codes.
#'
#' @return A list or vector of hexadecimal colour codes corresponding to the input colours.
#'
#' @details
#' The function iterates through each element in the `colours` input. If an element is a named colour
#' (not starting with '#'), it converts the name to its hexadecimal code. If the colour is already
#' in hexadecimal format, it is returned as is. The function validates the colour names and returns
#' an error for any invalid names.
#'
#' @note This function is used by `plot_sankey`.
#'
#' @importFrom grDevices col2rgb
#' @noRd
convert_colours <- function(colours) {
  if (is.list(colours) && !is.data.frame(colours) || is.vector(colours)) {
    colours_hex <- sapply(colours, function(col) {
      if (startsWith(col, "#")) {
        return(col)  # Already in hex, return as is
      } else {
        if (!col %in% colours()) {
          stop(paste("Invalid colour name:", col))
        }
        rgb_vals <- grDevices::col2rgb(col, alpha = FALSE) / 255
        return(grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], maxColorValue = 1))
      }
    }, USE.NAMES = TRUE)
  } else {
    stop("Colours must be a list or a vector.")
  }
  return(colours_hex)
}


#' Convert Base Font Size to Geom Font Size
#'
#' `convert_sizing` is a utility function that adjusts a base font size to a corresponding size suitable for `geom` elements in `ggplot2`. It's particularly useful for maintaining consistent and proportional font sizes across different plot components.
#'
#' @param base_size Numeric value representing the base font size.
#'
#' @return Numeric value representing the adjusted font size for `geom` elements.
#'
#' @details
#' The function calculates the `geom` font size by scaling the `base_size` with a predetermined ratio, ensuring that the text size in `geom` elements (like labels, titles, etc.) is proportionate and visually coherent with the rest of the plot. The ratio used in this function is based on the default settings of `ggplot2` where a base size of 14 corresponds to a `geom` size of 5.
#'
#' @examples
#' \dontrun{
#'   base_size <- 12
#'   geom_size <- convert_sizing(base_size)
#'   # Use `geom_size` in ggplot2's geom_text(), geom_label(), etc.
#' }
#'
#' @noRd
convert_sizing <- function(base_size) {
  geom_font_size = base_size / (14 / 5)
  return(geom_font_size)
}

#' Format Numeric Values as Percentage Labels
#'
#' `percent_label` is a utility function designed for formatting numeric values as percentage labels, suitable for use in `ggplot2` axis labels or anywhere percentages are required in a human-readable format. This function can handle both absolute and actual percentage values.
#'
#' @param absolute Logical flag indicating whether to use absolute values. If set to `TRUE`, the function converts all values to their absolute equivalents before formatting. Defaults to `FALSE`.
#'
#' @return A function that takes a numeric vector `x` and returns a character vector where each element is a formatted percentage string.
#'
#' @details
#' The `percent_label` function returns another function that formats numeric values as percentage strings. The returned function takes a numeric vector `x` and applies the formatting. The `absolute` parameter in `percent_label` determines whether the inner function uses the absolute value of each element in `x` or retains its original sign. For example, a value of -20 with `absolute = TRUE` would be formatted as "20%", whereas with `absolute = FALSE`, it would be "-20%".
#'
#' @examples
#' \dontrun{
#'   percentages <- c(-0.2, 0.3, 0.15)
#'   label_func <- percent_label(absolute = TRUE)
#'   label_func(percentages)  # "20%", "30%", "15%"
#'   label_func <- percent_label(absolute = FALSE)
#'   label_func(percentages)  # "-20%", "30%", "15%"
#' }
#'
#' @noRd
percent_label <- function(absolute = FALSE) {
  function(x) {
    if (absolute) {
      sprintf("%.0f%%", abs(x))
    } else {
      sprintf("%.0f%%", x)
    }
  }
}