scgUtils
================

## About
Welcome to `scgUtils`, an R package to help:
* Increase productivity by incorporating and formalising frequently used 
[**functions and charts**](#functions--charts) to run cleaner and more succinct code.
* Maintain brand [**guidelines and styles**](#guidelines--styles) by supplying colours and other 
dataviz standards.

*CAUTION: This package is still under construction and most functions need further testing to
ensure easy debugging for users.*

### Installation

The code below relies on the development version of `scgUtils`.
Install it with:

``` r
devtools::install_github("sarahcgall/scgUtils")
```

## Functions & Charts
The functions and formulae aim to reduce duplication of effort across 
projects, formalise various code, increase productivity, and reduce potential errors.

### Surveys
Survey data requires cleaning, iterating, and analysing. The following provides available functions
to help with these processes.

**Helper Functions**

The `grp_freq` function calculates the frequency of a variable in survey data by specified groups. This 
function is in place of [dplyr's](https://dplyr.tidyverse.org/reference/summarise.html) 
`group_by(y) %>% summarise(x = sum(x))` function.

```r
# GROUPED FREQUENCY DATA
# Sum unweighted data by 2 groups
df <- grp_freq(dataset,
               group = c("age_categories","gender"))
#    age_categories gender Freq
# 1        18 to 24   Male   84
# 2        25 to 34   Male  155
# 3        35 to 44   Male  180
# 4        45 to 54   Male  115
# 5        55 to 54   Male   38
# 6             65+   Male    6
# 7        18 to 24 Female   83
# 8        25 to 34 Female  153
# 9        35 to 44 Female  129
# 10       45 to 54 Female   57
# 11       55 to 54 Female   24
# 12            65+ Female    6

# Sum weighted data by 1 group and change the column names
df <- grp_freq(dataset,
               group = c("age_categories"),
               weight = "wgtvar",
               set_names = c("Age","n"))
#         Age         n
# 1  18 to 24  86.29264
# 2  25 to 34 225.19210
# 3  35 to 44 275.61526
# 4  45 to 54 280.12479
# 5  55 to 54 100.97521
# 6       65+  61.80000
```

The `grp_mean` function calculates the mean of a variable in survey data by specified groups. 
For non-grouped mean data, use `mean(var)` or `weighted.mean(var,weight)`.

```r
# GROUPED MEAN DATA
# Return a averages of a variable by group (weighted or unweighted)
df <- grp_mean(dataset,
               var = "age",
               group = "gender",
               weight = "wgtvar")
#   gender     Mean
# 1   Male 42.78670
# 2 Female 41.06441

# NB for non-grouped averages, use mean(var) or weighted.mean(var, weight)
```

The `grid_vars` function takes grid style survey questions and returns a data frame
with the frequency and percentage of each response variable. This is ordinarily required when survey's ask
questions such as "select all that apply". The function helps prepare data for analysis, comparison, and visualisation.
```r
# Example data:
#     wgt gender  Q1a Q1b Q1c
# 1  0.61   Male  Yes  No Yes
# 2  0.22 Female  Yes Yes Yes
# 3  1.81   Male   No  No Yes
# 4  0.90   Male  Yes  No  No
# 5  1.63 Female   No Yes  No
# 6  1.00 Female   No  No Yes
# ...

# Create list containing the column name and its associated variable name
vars <- list(Q1a = "Art",
             Q1b = "Automobiles",
             Q1c = "Birdwatching")

# Create data frame with binary variables
grid_vars(dataset,
            vars = vars,
            group = "gender",
            weight = "wgtvar")
#      Question Response gender     Freq Perc
#           Art      Yes   Male 275.3617   46
#   Automobiles      Yes   Male 320.1372   53
#  Birdwatching      Yes   Male 310.4357   52
#           Art      Yes Female 204.7525   48
#   Automobiles      Yes Female 212.0209   49
#  Birdwatching      Yes Female 203.9380   47
# ...

# NB. To see as a plot, see "Binary Plot" below.
```

<br>

**Crosstabs / Contingency Tables**

The `crosstab` function produces a 2x2 table in either a long or wide data frame format. The long format is useful
for further analysis or for use in plots. The wide format is also useful for further analysis or for easily viewing
individual results.
``` r
# GET CROSSTABS FOR TWO VARIABLES
# Long format crosstab with % data and no totals included. 
df <- crosstab(dataset,
               row_var = "Q1",
               col_var = "Gender", 
               weight = "wgtvar",
               totals = FALSE, # turn off totals (DEFAULT = TRUE)
               round_decimal=2) # set number of decimal points for values

# [1] Q1 x Gender: Chisq = 30.45 | DF = 4 | Cramer's V = 0.039 | p-value = 0
#               Q1 Gender    Freq  Perc
# 1    Very Likely Female 1971.54 75.52
# 2         Likely Female  446.31 17.10
# 3       Unlikely Female   47.22  1.81
# 4  Very Unlikely Female   51.72  1.98
# 5     Don’t Know Female   93.88  3.60
# 6    Very Likely   Male 1793.60 72.23
# 7         Likely   Male  540.24 21.75
# 8       Unlikely   Male   48.21  1.94
# 9  Very Unlikely   Male   54.98  2.21
# 10    Don’t Know   Male   46.30  1.86
```
<div align="left">
  <img src="man/figures/crosstab_plot.png" width="100%" />
</div>

``` r
# Wide format crosstab without weight variable and retained frequency data.
df <- crosstab(dataset,
               row_var = "Q1",
               col_var = "Gender", 
               round_decimal=2,
               statistics = FALSE, # turn off statistics (DEFAULT = TRUE)
               plot = FALSE, # turn off plot (DEFAULT = TRUE)
               format = "df_wide", # (DEFAULT = "df_long")
               convert_to = "frequency") # (DEFAULT = "percent")

# A tibble: 5 x 4
#   Q1            Total Female  Male
#   <fct>         <dbl>  <dbl> <dbl>
# 1 Very Likely    4009   2319  1690
# 2 Likely          854    436   418
# 3 Unlikely         75     37    38
# 4 Very Unlikely    68     35    33
# 5 Don’t Know       88     70    18
```

The `compile` function iterates through all the available variable and grouping options that you want
in order to provide a full set of crosstabs. Each crosstab contains a statistic to understand the association
between the two variables.

*NB caution using chi-square and p-values when the sample size is >500 or <5. In these circumstances, use 
Cramer's V or Fisher's Exact test, respectively.* 

Once the function has run, the data is saved to a csv in your project directory unless stated otherwise.
``` r
# GET CROSSTABS FOR ALL VARIABLES
compile(dataset, 
        row_vars = c("Q1", "Q2"),
        col_vars = c("Gender", "VI"),
        weight = "wgtvar",
        name = "crosstabs") # set name to save .csv as (DEFAULT = "table")

#                             Gender        VI
# Q1                   Total  Male  Female  Gov.  I would not vote  Not enrolled  Opp.  Other
#          Very likely   62%   67%     57%   73%                0%            9%   76%    39%
#      Somewhat likely   18%   15%     22%   19%                3%            5%   19%    34%
#      Not very likely    5%    4%      7%    5%               19%            0%    3%     7%
#    Not at all likely    6%    8%      6%    0%               55%           13%    0%     3%
#               Unsure    8%    6%      9%    3%               23%           73%    2%    17%
# Weighted sample size   991   480     511   347                90            26    419   109
# V6 x Gender: Chisq = 21.382 | DF = 4 | Cramer's V = 0.073 | p-value = 0.000     
# V6 x VI: Chisq = 772.347 | DF = 16 | Cramer's V = 0.441 | p-value = 0.000 
# 
#                             Gender        VI
# Q2                   Total  Male  Female  Gov.  I would not vote  Not enrolled  Opp.  Other
# ...

```

The `compile` function can also iterate through all the available variable and grouping options to provide a list 
of statistics. In either formatting options, there is an option of not saving the data frame to a csv and to instead
return the data frame within your R environment.

``` r
# GET STATISTICS
compile(dataset, 
        row_vars = c("Q1", "Q2"),
        col_vars = c("Gender", "Edu", "VI"),
        weight = "wgtvar",
        format = "statistics", # set format to "statistics" (DEFAULT = "csv")
        save=FALSE) # set to FALSE if you do not want to save to a .csv (DEFAULT = TRUE)

#   Row_Var Col_Var Size    Chisq DF CramersV p_value
# 1      Q1  Gender  991   23.757  4    0.077   0.000
# 2      Q1     Edu  991   44.034 20    0.105   0.001
# 3      Q1      VI  991  694.206 16    0.418   0.000
# 4      Q2  Gender  991   64.520 16    0.064   0.000
# 5      Q2     Edu  991  170.355 80    0.104   0.000
# 6      Q2      VI  991 2458.172 64    0.394   0.000
```

<br>

### Charts
**Population Plot**

The `plot_popn` function returns a [ggplot2](https://ggplot2.tidyverse.org/reference/theme.html)
chart to help visualise the population structure of the survey data. The population pyramid
is provided as a percentage and can return the average age of Male vs Female data if the actual
age numbers were collected within the survey.
``` r
# Create plot using age groups and age intervals included to return average age
plot_popn(dataset,
          age_group = "age_categories",
          gender = "gender",
          weight = "wgtvar",
          age_int = "age")
```
<div align="left">
  <img src="man/figures/popn_plot1.png" width="100%" />
</div>

A group comparator option will be added in the future to provide a way to visually compare groups against the
average.

``` r
plot_popn(dataset,
          age_group = "age_categories",
          gender = "gender",
          weight = "wgtvar",
          group = "housing_categories")
```
<div align="left">
  <img src="man/figures/popn_plot2.png" width="100%" />
</div>

**Personality Plot**

The `plot_bigfive` function returns a [ggplot2](https://ggplot2.tidyverse.org/reference/theme.html)
chart to help visualise the personality profile of the survey data. This radar chart is primarily
to visualise the Big Five personality traits (neuroticism, extroversion, openness, agreeableness, and
conscientiousness) but can be amended for other quantitative data types with a scale between 0 and 100.

When a group is provided, the function returns faceted plots with the variables within the group plotted 
on top of the average. This provides an easy comparison between the variable and the rest of the cohort in the
survey.

``` r
# Create single plot using unweighted data
plot_bigfive(dataset,
             big_five = c("Neuroticism", "Extroversion", "Openness", "Agreeableness", "Conscientiousness"))
```
<div align="left">
  <img src="man/figures/bigfive_plot1.png" width="100%" />
</div>

``` r 
# Create faceted plot using age groups and weighted data
plot_bigfive(dataset,
             big_five = c("Neuroticism", "Extroversion", "Openness", "Agreeableness", "Conscientiousness"),
             group = "Gender",
             weight = "wgtvar")
```
<div align="left">
  <img src="man/figures/bigfive_plot2.png" width="100%" />
</div>

**Binary Plot**

The `plot_binary` function returns a [ggplot2](https://ggplot2.tidyverse.org/reference/theme.html)
chart to help visualise binary grid-based questions (e.g., "Yes" vs "No"). See `grid_vars` for more
information.

``` r
# Create list
vars <- list(Q1a = "Art",
             Q1b = "Automobiles",
             Q1c = "Birdwatching"
             ...)
# Create plot             
plot_binary(dataset,
            vars = vars,
            group = "gender",
            weight = "wgtvar",
            return_var = "Yes")
```
<div align="left">
  <img src="man/figures/binary_plot.png" width="100%" />
</div>

**Sankey Plot**

The `plot_sankey` function returns a [d3.js](https://d3js.org/) 
sankey chart to help visualise the flow of data.

``` r
# Libraries
library(tidyverse)

# =====================================#
# Upload split voting data
df <- scgElectionsNZ::get_data("split_total")

# Prepare Sankey Data
df <- df %>%
  filter(Year==2023) %>% # get 2023 election data only
  # combine unsuccessful minor parties into "Other" category
  mutate(List_Party = ifelse(
    List_Party %in% c("Labour Party","ACT Party","Maori Party","Green Party","National Party","NZ First","Informal"),
    List_Party, "Other"
  )) %>%
  mutate(Electorate_Party = ifelse(
    Electorate_Party %in%
      c("Labour Party","ACT Party","Maori Party","Green Party","National Party","NZ First","Informal"),
    Electorate_Party, "Other"
  )) %>%
  group_by(List_Party, Electorate_Party) %>%
  summarise(Vote = sum(Votes)) %>%
  ungroup()

# A tibble: 64 x 3
#   List_Party  Electorate_Party    Vote
#   <chr>       <chr>              <dbl>
# 1 ACT Party   ACT Party         68692.
# 2 ACT Party   Green Party        2095.
# ...
  
# =====================================#
# Look up colours
colour_pal("polNZ")
# $`ACT Party`
# [1] "#ffd006"
# $`Green Party`
# [1] "#45ba52"
# ...

# Create Sankey
plot_sankey(
  data = df,
  source = "Electorate_Party", # left side of sankey
  target = "List_Party", # right side of sankey
  value = "Vote",
  colours = '"#ffd006","#45ba52","#d5cdb9","#D82A20","#B2001A","#000000","#00529F","#cdcdd1"',
  fontSize = 20, # reduce font size from default
  width = 1600 # increase width form default
) %>%
  # save from viewer to html
  htmlwidgets::saveWidget(file="sankey_2023.html", selfcontained = TRUE)
```
<div align="left">
  <img src="man/figures/sankey_plot.png" width="100%" />
</div>


## Guidelines & Styles
The colours and layouts are guides only and are not rigid rules. 
They aim to provide consistency across all dataviz design and aid in 
the decision-making process.

### Chart layout
The layout for charts aims to place the emphasis on the data by making reducing any excess
clutter. This includes choosing lighter shades of grey for axes, grid lines, and texts, and removing
any borders.

The `theme_scg` function is a [ggplot2](https://ggplot2.tidyverse.org/reference/theme.html) theme to 
assist with achieving this goal. Individual charts can easily be customised by adding `+ theme()` at 
the end to amend. The base size of the font and font family can also be amended.

``` r
# USING THE SCG PLOT THEME
ggplot(data=df, aes(x = x, y= y, fill=reorder(group, y))) +
   geom_bar(stat="identity", 
            width=0.8, 
            position = position_dodge(width=0.9)) +
   scale_fill_manual(values=colour_pal("catExtended")) +
   labs(title = "Title", 
        x= "x", 
        y= "", 
        fill = "y") +
   theme_scg()

# Make customisations to the theme:
ggplot(data=df, aes(x = x, y= y, fill=reorder(group, y))) +
   geom_bar(stat="identity") +
   scale_fill_manual(values=colour_pal("catSimplified")) +
   labs(title = "Title", 
        x= "x", 
        y= "", 
        fill = "y") +
   theme_scg(base_size = 12, base_font = "Roboto") +
   theme(panel.grid.major.x = element_blank()) # turn off x axis grid lines
```

<br>

### Colours
Colours will be amended in the future. In the meantime, colours and colour palettes
are divided into the following categories:
* *Individual:* individual colour hex codes
  * see `colour_display("All")` for all available colours
* *Political:* colours that correspond to official party colours
  * `polAus`
  * `polUK`
  * `polNZ`
* *Categorical:* colours for representing nominal or categorical
  * `catSimplified`
  * `catExtended`
* *Sequential:* scale of colours for ordered data that progresses from low to high (single hue)
  * `seqGreen`
  * `seqBlue`
  * `seqRed`
* *Diverging:* scale of colours for representing two extremes at the low and high end of the
data (multi-hue)
  * `divRedBlue`
  * `divBlueGreen`


The `colour_display` function provides a way of visualising and testing colours before using
them in graphs. All of the above options can be tested, including the ability to test assigning
colours to your own levels.
``` r
# VISUALISE AVAILABLE COLOURS
# View all individual colours
colour_display(palette = "All")
```
<div align="left">
  <img src="man/figures/colour_display_all.png" width="60%" />
</div>

``` r
# View individual colour
colour_display(palette = "Jaffa")
```
<div align="left">
  <img src="man/figures/colour_display_jaffa.png" width="60%" />
</div>

``` r
# View full pallette
colour_display(palette = "polUK")
```
<div align="left">
  <img src="man/figures/colour_display_polUK.png" width="60%" />
</div>

``` r
# View sequential colour palette with 7 levels
colour_display(palette = "seqGreen", 
               n = 7)
```
<div align="left">
  <img src="man/figures/colour_display_seqGreen.png" width="60%" />
</div>

``` r
# View diverging colour palette with 5 levels with assigned values
colour_display(palette = "divBlueGreen", 
               n = 5, 
               assign = c("Very Likely",
                          "Likely",
                          "Neutral",
                          "Unlikely",
                          "Very Unlikely"))
```
<div align="left">
  <img src="man/figures/colour_display_divBlueGreen.png" width="60%" />
</div>

The `colour_pal` function returns a single hex code, a vector of colours (discrete or
continuous) or a list of colours to assign levels within your dataset. This can be utilised
within ggplot2.
``` r
# RETURN COLOURS
Return individual colour
colour_pal(pal_name = "Jaffa")
# [1] "#e78e47"

# Return full palette vector
colour_pal(pal_name = "catExtended")
# [1] "#478c5b" "#374e8e" "#df7c18" "#ac004f" "#4fbbae" "#ce4631" "#006d64" "#1b87aa" "#e3b13e" "#ae49a2" "#383751" "#704600" "#93a345" "#7e7e8f"
#[15] "#d5cdb9" "#a07bde" "#8aabfd" "#a08962"

# Return political colour palette
colour_pal(pal_name = "polAus") # returns assigned list
# $`Labor Party`
# [1] "#de2b33"

# $Coalition
# [1] "#1c4f9c"

# $Greens
# [1] "#039d3a"

# $`One Nation`
# [1] "#ff6c00"

# $`United Australia Party`
# [1] "#feed01"

# $Other
# [1] "#cdcdd1"

# Return palette with 5 colours and assigned levels for each colour
colour_pal(pal_name = "divBlueGreen", 
           n = 5, 
           assign = c("Very Likely",
                      "Likely",
                      "Neutral",
                      "Unlikely",
                      "Very Unlikely"))
# $`Very Likely`
# [1] "#1b87aa"

# $Likely
# [1] "#70a9c1"

# $Neutral
# [1] "#c7c7c7"

# $Unlikely
# [1] "#acb58a"

# $`Very Unlikely`
# [1] "#93a345"

# USING IN ggplot2
ggplot(data=df, 
       aes(x=x, y=y, fill=group)) +
   geom_bar(stat="identity") +
   scale_fill_manual(values = colour_pal("catSimplified")) +
   theme_minimal() +
   theme(axis.line = element_line(colour=colour_pal("French Grey"))
```


### Other resources
The following contains a number of useful links to
* [Data Wrapper Colours for Data Viz Style Guide](https://blog.datawrapper.de/colors-for-data-vis-style-guides/): 
view other style guides and colours uses from companies such as the Economist, the FT, the NYT, EuroStat, etc.
* [Adobe Colour Wheel](https://color.adobe.com/create/color-wheel) or 
[Viz Palette](https://projects.susielu.com/viz-palette): utilise accessibility 
tools to test if the palette is colour blind friendly.
* [Chroma.js Color Palette Helper](https://www.vis4.net/palettes/): develop sequential or diverging colour scales

## Other Packages
This package serves as a central hub for Sarah C Gall Ltd. Several additional 
packages are now available which either complement or assist in project work. 
Additional packages include:
* `scgElectionsNZ`: a package which provides datasets of NZ general elections
* `scgElectionsAUS`: TBC
* `scgElectionsUK`: TBC