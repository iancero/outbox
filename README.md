
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Outbox

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Many data analysis outputs need to leave the R ecosystem shortly after
they’re created. The goal of this package is thus to provide basic
“outbox” functionality to the R data analysis workflow. This is achieved
with a standardized wrapper function - syntactic sugar using existing
packages - that behaves the same way across common types of output and
file formats.

## Installation

The outbox package is still in early development. You can install the
development version of outbox from [GitHub](https://github.com/) with:

``` r
# install.packages('devtools')
devtools::install_github('iancero/outbox')
```

## Examples

Outbox provides a single function `write_output()` designed to make your
analysis workflow similar to a physical paper workflow. When an item is
complete, you simply drop it in the your outbox.

### Same function across inputs/outputs

The outbox experience should be the same, regardless of whether the
specific output is a `gtsummary` table headed to a `.xlsx` workbook…

``` r
library(gtsummary)
library(outbox)

my_table <- tbl_summary(mtcars)

write_output(my_table, 'my_excel_workbook.xlsx')
```

…or a `ggplot` figure headed to a `.docx` document.

``` r
library(ggplot2)

my_plot <- ggplot(mtcars, aes(wt, mpg)) +
  geom_point()

write_output(my_plot, 'my_word_doc.docx')
```

### Keep appending to the same outbox

Much like a physical outbox, the `write_output()` is also designed to
simply append each new output object to the end of the existing file.
This allows you to simply set the outbox path at the beginning and drop
new output there as it is created.

``` r
my_outbox <- 'my_word_doc.docx'

my_plot <- ggplot2::ggplot(mtcars, aes(wt, mpg)) +
  ggplot2::geom_point()

write_output(my_plot, my_outbox)
```

On subsequent calls, you can even drop the path argument for
convenience.

``` r
my_table <- gtsummary::tbl_summary(mtcars)

write_output(my_table)
```

### Add labels

Again with a physical outbox, you sometimes want to add brief sticky
notes to remind you what you are looking at later. In the outbox
package, that is achieved by passing a string to the `label` parameter
of `write_output()`. That label is then used as the sheet name for
`.xlsx` files or as a [level 1
header](https://support.microsoft.com/en-us/office/headers-and-footers-in-word-b693b4fb-0d23-4109-a621-1b828b824454)
above the output in a `.docx` file.

``` r
write_output(my_table, label = 'Descriptive Statistics')
```

### Add captions

Basic support for captions of figures (and in the name of symmetry, also
for tables) is provided too. Depending on the type of document, the
caption will either appear above (`.xlsx`) or below (`.docx`) the output
itself.

``` r
fig_caption <- 'This figure depicts the relationship between weight and MPG'

write_output(my_plot, label = 'Wt-vs-MPG Fig', caption = fig_caption)
```

### label vs caption

The difference between the `label` and `caption` is that label has a
special role in the document it is sent to. In a `.docx` document, it
will be a header at the top of a page. Visually, that will make it look
more like a title. It has the additional benefit of being automatically
detectable by Word’s table of contents and other features. Likewise,
`labels` in `.xlsx` documents will serve as sheet names. Because `label`
will serve this titular role in both documents, it should ideally be
short and simply used to help the document recipient locate whatever
they are looking for.

In contrast, the `caption` string is just plain text that will appear
either above (`.xlsx`) or below (`.docx`) the output itself. It is
suitable for much longer descriptions, capable of providing detail and
context to the reader.

Note, neither `label` nor `caption` support anything other than plain
text (e.g., Rmarkdown).

## Why do we need outbox?

Although many analysis output classes and their associated packages
already have reliable mechanisms for exporting an output object, these
functions are variable from package to package - and sometimes even
within functions of the same package.

For example, the excellent `gtsummary` package uses `flextable` to
export tables to `.docx` files and `huxtable` to export those same
tables to `.xlsx` files. This is a good choice that results in high
quality output to both sources, but creates a variable workflow across
the two types of output.[^1]

To see this in action, note that when we want to send an `gtsummary`
table (`trial_tbl`) to an `.xlsx` document, only one step is required.

``` r
library(gtsummary)

trial_tbl <- trial |> 
  tbl_summary()

xlsx_path <- tempfile(fileext = '.xlsx')

trial_tbl |>
  gtsummary::as_hux_xlsx(file = xlsx_path)
```

In contrast, when we want to send the same `gtsummary` table to a word
document, we need two steps. We also need to work with a different
argument for our target file (i.e., `file =` for `.xlsx` vs `path =` for
`.docx`).

``` r
docx_path <- tempfile(fileext = '.docx')

trial_tbl |>
  gtsummary::as_flex_table() |>
  flextable::save_as_docx(path = docx_path)
```

In each individual case, this non-standardization is only a minor issue.
However, a single data analysis will likely involve several differed
output classes, in turn exported to multiple different file types. The
complexity grows quickly, slowing down the analysis process and making
debugging more difficult.

The approach outbox takes to resolve these problems is to offer a single
wrapper function `write_output()`, which is ready to receive multiple
output classes and output file extensions - at least for the most common
classes and file types.

## Supported output classes and file types

Currently, the supported output classes include:

- `"gtsummary"`
- `"ggplot"`

Supported output file formats include:

- `.xlsx`
- `.docx`.

Additional output classes and file formats are currently under
consideration for the future. However, any future support will only ever
be expanded to (a) especially common classes and formats, for which (b)
there are already existing specialty export functions that can be
streamlined with `write_output()`. This is because outbox aspires only
to streamlining, not adding functionality or additional control (see
below).

## Package scope: What outbox will *not* do

Note, outbox has intentionally small aspirations. It’s goal is only to
standardize and streamline existing output infrastructure and provide
only very basic convenience improvements (e.g., adding simple labels to
output during export). It is not intended to add any meaningful
functionality that doesn’t already exist. To abide by those constraints,
outbox will NOT:

- **Write multiple objects in a single call**. Although this
  functionality was initially considered for `write_output()`,
  experience has shown that it often reduces the interpretability of the
  files it produces. To discourage the practice of dropping collections
  of (often unlabelled) output objects into files all at once,
  `write_output()` does not support lists of objects.
- **Wrangle output objects into the correct format.** If you are not
  starting with an object in a supported format, outbox is unable to
  help.
- **Tweak look and feel (formatting) of outputs.** The outbox package is
  designed simply to call existing packages in a standardized way. If
  you want your output formatted differently than the defaults given by
  the packages on which outbox depends, it will be important to use
  those packages directly.

[^1]: To be fair to `gtsummary`, which is admittedly one of my own
    favorite packages, this is a cherry-picked example to demonstrate a
    point. Elsewhere in that package, several additional output
    mechanisms are available - many of which are helpfully similar from
    function to function.
