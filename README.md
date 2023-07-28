
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Outbox

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of this package is to provide a basic `outbox` for your data
analysis workflow, exclusively by streamlining existing functions
available in the packages that produced the original output.

## A standardized export function

The desired result is a standardized process that makes getting analysis
output to its final destination work like setting a completed paper
document in a physical outbox. This should be true, regardless of
whether the specific output is a `gtsummary` table headed to a `.xlsx`
workbook…

``` r
library(gtsummary)
#> #Uighur
library(ggplot2)
library(outbox)

my_table <- gtsummary::tbl_summary(mtcars)

write_output(my_table, 'my_excel_workbook.xlsx')
```

…or a `ggplot` headed to a `.docx` document.

``` r
my_plot <- ggplot2::ggplot(mtcars, aes(wt, mpg)) +
  ggplot2::geom_point()

write_output(my_plot, 'my_word_doc.docx')
```

## Sequentially append output objects as they are made

Much like a physical outbox, the `write_output()` is also designed to
simply append each new output object to the end of the existing file.
This allows you to simply set the outbox path at the beginning and drop
new output there as it is created.

``` r
my_outbox <- 'my_word_doc.docx'

my_plot <- ggplot2::ggplot(mtcars, aes(wt, mpg)) +
  ggplot2::geom_point()

write_output(my_plot, my_outbox)

my_table <- gtsummary::tbl_summary(mtcars)

write_output(my_table, my_outbox)
```

## Add labels

Sometimes with a physical outbox, you want to add brief sticky notes to
remind you what you are looking at later. In the `outbox` package, that
is achieved by passing a string to the `label` parameter of
`write_output()`. This label is then used as the sheetname for .xlsx
files or as a level 1 header above the output in a .docx file.

``` r
write_output(my_table, path = my_outbox, label = 'Descriptive Statistics')
```

## The problem

Analysis output (e.g., results tables, plots) are *born* in R / Rmd
files, but they often need to *live* in more common file formats (e.g.,
`.docx`) shortly after they are created. Moreover, they typically need
to live alongside several of their *sibling* plots and tables in the
same output file.

Although many analysis output classes and their associated packages
already have reliable mechanisms for exporting an output object, these
functions are variable from package to package (and sometimes within
functions of the same package).

For example, the excellent `gtsummary` package makes the thoughtful
choice of using `flextable` to export tables to `.docx` files and
`huxtable` to export those same tables to `.xlsx` files. This is a good
choice that results in high quality output to both sources, but creates
a variable workflow across the two types of output.[^1]

To see this in action, note that when we want to send an output table
(`trial_tbl`) to an `.xlsx` document, only one step is required.

``` r
library(gtsummary)

trial_tbl <- trial |> 
  tbl_summary()

xlsx_path <- tempfile(fileext = '.xlsx')

trial_tbl |>
  gtsummary::as_hux_xlsx(file = xlsx_path)
```

In contrast, when we want to send the same table to a word document, we
need two steps. We also need to work with a different argument for our
target file (i.e., `file` for `.xlsx` vs `path` for `.docx`).

``` r
docx_path <- tempfile(fileext = '.docx')

trial_tbl |>
  gtsummary::as_flex_table() |>
  flextable::save_as_docx(path = docx_path)
```

The approach `outbox` takes to resolve these problems is to offer a
single wrapper function `write_output()`, which is ready to receive
multiple output classes and output file extensions.

Currently, the supported output classes include:

- `"gtsummary"`
- `"ggplot"`

Supported output file formats include:

- `.xlsx`
- `.docx`.

**NOTE:** `outbox` has intentionally small aspirations. It’s goal is to
standardize and streamline existing output infrastructure and provide
only very basic convenience improvements (e.g., adding a time stamp
output file names). It does not intend to do anything more than provide
syntactic sugar to the existing packages that run underneath it. To
maintain its role as a basic convenience wrapper package, it will not
help wrangle output classes and it will not help format output.

## Installation

The `outbox` package is still in early development. You can install the
development version of outbox from [GitHub](https://github.com/) with:

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

[^1]: To be fair to `gtsummary`, which is admittedly one of my own
    favorite packages, this is a cherry-picked example to demonstrate a
    point. Elsewhere in the package, it actually provides several
    additional output mechanisms too - many of which are helpfully
    similar from function to function.
