
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Outbox

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The `outbox` package provides basic wrapper functions to standardize the
syntax and workflow across some common output classes and output file
formats in R.

This standardization and streamlining is inspired by two major problems
in the existing eco-system: 1. Although many analysis classes/packages
already have reliable mechanisms for exportation, they are collectively
inconsistent from function to function and package to package (e.g.,
different exportation pipelines, different export function parameters).
For example, as of this writing, `gtsummary` uses `flextable` to export
tables to `.docx` files and `huxtable` to export those same tables to
`.xlsx` files. This is a good choice, resulting in high quality output
to both sources, but creates a variable workflow across the two types of
output. Although most differences are small, they build up
multiplicatively (e.g., already 2 output classes \* 2 output filetypes =
4 unique workflows). 2. Many packages offer only “one-shot” export
functions that, for example, produce a one-page Word file containing
exactly one figure. They lack built-in support for exporting several
output objects to the same document - either sequentially or at the same
time.

The approach `outbox` takes to resolve these problems is to offer a
single wrapper function `write_output()`, which is ready to receive
multiple output classes and output file extensions.

Currently, the supported output classes include: - `"gtsummary"` -
`"ggplot"`

Supported output file formats include: - `.xlsx` - `.docx`.

**NOTE:** `outbox` has intentionally small aspirations. It’s goal is to
standardize and streamline existing output infrastructure and provide
only very basic convenience improvements (e.g., adding a time stamp
output file names). It does not intend to do anything more than provide
syntactic sugar to the existing packages that run underneath it. To
maintain its role as a basic convenience wrapper package, it will not
help wrangle output classes and it will not help format output.

## Installation

You can install the development version of outbox from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("iancero/outbox")
```

## Example

The workhorse of the `outbox` package is `write_output()`, which can
automatically detect the output class and output file type.

``` r
library(gtsummary)
library(outbox)

path <- tempfile(fileext = '.xlsx')

tbl_1 <- trial %>%
  tbl_summary(include = c(age, grade, response)) %>%
  modify_caption('Table 1. Drug trial results')

# starting with a blank output file (append = FALSE)
write_output(tbl_1, path, label = 'Drug trial results', append = FALSE)
```

It can then add additional tables to the end of the document created
above.

``` r
fit <- glm(response ~ age + stage, trial, family = binomial)
tbl_2 <- fit %>% 
  tbl_regression(exponentiate = TRUE)

write_output(tbl_2, path, label = 'Regression coefficients', append = TRUE)
```

Plots are also supported using the same function call.

``` r
library(ggplot2)

plt_1 <- ggplot(mpg, aes(displ, hwy, colour = class)) + 
  geom_point()

write_output(plt_1, path, label = 'Regression coefficients', append = FALSE)
#> Warning: Workbook does not contain any worksheets. A worksheet will be added.
```
