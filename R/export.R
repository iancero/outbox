detect_output_type <- function(x){
  supported_classes <- c('gtsummary', 'ggplot')
  detected_class <- which(supported_classes %in% class(x))

  if (length(detected_class) != 1) {
    stop(
      paste(
        'No supported output classes detected.',
        'Outbox currently supports the classes: "gtsummary", "ggplot"',
        'Call class(x) to check one of these classes is present in x.'))
  }

  cls <- supported_classes[detected_class]

  cls
}

detect_output_ext <- function(path){
  supported_exts <- c('xlsx', 'docx')
  detected_ext <- which(supported_exts %in% tools::file_ext(path))

  if (length(detected_ext) != 1) {
    stop(
      paste(
        'No supported output extensions detected.',
        'Outbox currently supports the extensions: "xlsx", "docx"',
        'Check path string to ensure one of these extensions is present'))
  }

  ext <- supported_exts[detected_ext]

  ext
}


construct_output_function <- function(x, path){
  output_type <- detect_output_type(x)
  output_ext <- detect_output_ext(path)
  output_func <- glue::glue('{output_type}_to_{output_ext}')

  output_func
}


#' Write output to a document
#'
#' Takes an object to be output and writes that object to a file. Currently,
#' supported output objects include \code{gtsummary} table and \code{ggplot}
#' plots. Supported document formats include \code{.xlsx} and \code{.docx}.
#'
#' @param x A table with class "gtsummary" or a plot with class "ggplot"
#' @param path Path to the document, ending in \code{.xlsx} or \code{.docx}. If
#' it does not yet exist, it will be created.
#' @param label Character string. This will be used as either the name of the
#' sheet (must be unique for xlsx) this object will receive in the \code{.xlsx}
#' document or it will be used as the heading on this object's page in the
#' \code{.docx} document. If \code{FALSE} (the default), sheets will be labelled
#' by sheet number in the \code{.xlsx} workbook or by output type in the
#' \code{.docx} document. That is, if a workbook already has two sheets, this
#' new table's sheet name will be "Sheet 3". Alternatively, if the function is
#' working with a table being output to a \code{.docx} document, the heading of
#' the new page will simply be "Table".
#' @param append If \code{TRUE} (the default) the function will attempt to
#' append the newly created sheet/page to the end of the document, leaving all
#' the earlier components of the document intact. If \code{FALSE}, the function
#' will behave similarly to \code{base::write.csv()} and will write over the
#' entire original document. That is, it will delete the original document,
#' generate a new blank document, and finally place the newly created sheet
#' inside that blank document.
#' @param toc If a new \code{.docx} document is being created, should it also
#' include a table of contents?
#' @param update_fields  Should the table of contents fields be updated after
#' the addition of this new output object (\code{x})? Note, \code{.docx}
#' documents will not auto-update TOC fields on their own. Normally, they need
#' MS Word to open them (and then the user will be prompted about whether they
#' want Word to attempt the updates it detects). If this parameter is set to
#' \code{TRUE}, the function will attempt to perform the updates on the object
#' itself. Note, this requires that the user has MS Word installed on the
#' current machine. Additionally, it tends to take several seconds to complete
#' this update, so the default choice is set to \code{FALSE}.
#' @param height The desired height of the plot (in inches).
#' @param width The desired width of the plot (in inches).
#' @param res The desired resolution of the plot (in ppi/dpi)
#' @param ... Additional arguments to be passed to internal functions.
#'
#'
#' @details
#'
#' The \code{write_output()} function should be the only one of these
#' functions the user calls on a regular basis. Under the hood, this function
#' detects the object type and the file extension supplied by the user, then
#' chooses one of the other more specific functions to apply. For this reason,
#' it should be uncommon that the user needs to use any of the more specific
#' functions directly.
#'
#' Note, the functions given here are note designed to do much more
#' than the existing packages that they call underneath. For example, the
#' \code{gtsummary::as_hux_xlsx()} function already delivers much of the
#' convenience of \code{write_output()}.
#'
#' So instead, the major contribution of these functions is a streamlined
#' workflow and interface across common output types and document formats. In
#' addition, these functions facilitate the repetitive appending of additional
#' output to the same file, which is useful for large analyses with multiple
#' important outputs.
#'
#' @return (invisibly) The original, unmodified output object (\code{x})
#' @export
#'
#' @examples
#' library(outbox)
#' library(gtsummary)
#'
#' tbl_1 <- trial |>
#'   tbl_summary(include = c(age, grade, response)) |>
#'   modify_caption('Table 1. Drug trial results')
#'
#' path <- tempfile(fileext = '.xlsx')
#'
#' # starting with a blank output file (append = FALSE)
#' write_output(tbl_1, path, label = 'Drug trial results', append = FALSE)
#'
#' # add an additional table to that same path, with append = TRUE
#' gtsummary_to_xlsx(tbl_1, path, label = FALSE, append = TRUE)
#' @order 1
write_output <- function(x, path, label = FALSE, caption = NULL,
                         append = TRUE, ...) {
  dot_args <- rlang::list2(...)
  output_func <- construct_output_function(x, path)

  rlang::exec(
    .fn = output_func,
    x = x,
    path = path,
    label = label,
    caption = caption,
    append = append,
    !!!dot_args)

  invisible(x)
}
