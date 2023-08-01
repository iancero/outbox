outbox_env <- new.env(parent = emptyenv())
assign('last_path', value = NULL, envir = outbox_env)

#' Retrieve the last path used in write_output()
#'
#' This function returns the last path used in a previous call to
#' write_output(). If no path has been used yet, it returns NULL. It is desiged
#' to be used in conjunction with \code{write_output()}.
#'
#' @return The last path used in \code{write_output()}, or \code{NULL} if no
#' path has been used yet.
#'
#' @family write_output-related functions
#'
#' @export
last_path <- function() {
  get('last_path', envir = outbox_env)
}



#' Detect the Output Type from an Object
#'
#' This function detects the output type from a given object. It checks if the
#' object's class matches one of the supported classes ('gtsummary' or
#' 'ggplot'), and throws an error if the extension is not a supported type.
#'
#' @param x An output object (e.g. table) from which to detect the output type.
#'
#' @return A character vector indicating the detected output type. If the
#' detected class is not one of the supported classes ('gtsummary' or 'ggplot'),
#' the function will throw an error.
#'
#' @details
#'
#' This function is used internally by \code{write_output()}. Generally, the end
#' user should not have a reason to call it directly. It is exported instead as
#' a convenience function, in case the user needs to debug something
#' (e.g., to understand how the \code{write_output()} function is assessing
#' their output objects internally).
#'
#' @family write_output-related functions
#'
#' @examples
#' library(outbox)
#'
#' my_ggplot <- ggplot2::ggplot(mtcars, ggplot2::aes(x = mpg, y = hp))
#' detect_output_type(my_ggplot)
#'
#' @export
detect_output_type <- function(x){
  supported_classes <- supported('classes')
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


#' Detect the Output Extension from a File Path
#'
#' This function detects the output extension from a given file path. It checks
#' if the file extension matches one of the supported extensions ('xlsx' or
#' 'docx'), and throws an error if the extension is not a supported type.
#'
#' @param path A character vector representing the file path from which to
#' detect the output extension.
#'
#' @details
#'
#' This function is used internally by \code{write_output()}. Generally, the end
#' user should not have a reason to call it directly. It is exported instead as
#' a convenience function, in case the user needs to debug something
#' (e.g., to understand how the \code{write_output()} function is assessing
#' their output objects internally).
#'
#' @return A character vector indicating the detected output extension. If the
#' detected extension is not one of the supported extensions ('xlsx' or 'docx'),
#' the function will throw an error.
#'
#' @family write_output-related functions
#'
#' @examples
#' library(outbox)
#'
#' path <- 'example.xlsx'
#' detect_output_ext(path)
#'
#' @export
detect_output_ext <- function(path){
  supported_exts <- supported('extensions')
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


#' Construct Output Function Name
#'
#' This function is used by the generic \code{write_output()} function to make
#' the appropriate specific output function call (e.g.,
#' \code{gtsummary_to_docx}) under the hood.
#'
#' @param x An object from which to detect the output type.
#'
#' @param path A character vector representing the file path from which to detect
#' the output extension.
#'
#'
#' @details
#'
#' It constructs the name of the specific output function to be used (e.g.,
#' \code{gtsummary_to_docx}), based on the detected output type and output
#' extension. The output function name is in the format
#' '{output_type}_to_{output_ext}'.
#'
#' This function is intended for internal use only. It is not exported to the
#' end user.
#'
#' @return A character vector representing the name of the constructed output
#'         function. If the output type or extension is not supported, the function
#'         will throw an error.
#'
#' @keywords internal
#'
#' @family write_output-related functions
#'
#' @examples
#' library(outbox)
#'
#' my_ggplot <- ggplot2::ggplot(mtcars, ggplot2::aes(x = mpg, y = hp))
#' my_path <- 'output.xlsx'
#' outbox:::construct_output_function(my_ggplot, my_path)
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
#' it does not yet exist, it will be created. Note, if the path is not provided
#' (i.e., when set to its default, \code{path = NULL}), it will use the last
#' path used in a previous call to write_output() (which is retrieved via the
#' \code{last_path()} function).
#' @param label Character string. This will be used as either the name of the
#' sheet (must be unique for xlsx) this object will receive in the \code{.xlsx}
#' document or it will be used as the heading on this object's page in the
#' \code{.docx} document. If \code{FALSE} (the default), sheets will be labelled
#' by sheet number in the \code{.xlsx} workbook or by output type in the
#' \code{.docx} document. That is, if a workbook already has two sheets, this
#' new table's sheet name will be "Sheet 3". Alternatively, if the function is
#' working with a table being output to a \code{.docx} document, the heading of
#' the new page will simply be "Table".
#' @param caption Either \code{NULL} (the default) or a character string. If the
#' argument is \code{NULL}, nothing will be added to the document page/sheet. If
#' the argument is a character string, then this will be added as a text near
#' the input object (\code{x}) in the resulting document page/sheet. If the
#' output format is \code{.xlsx}, then the caption will be added to cell A1. If
#' the output format is \code{.docx}, then it will be appended as "Normal" style
#' text two lines below the primary \code{x} input.
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
#' functions directly. However, they are made available to the end user to
#' potentially assist in debugging (e.g., the user wants to assess how the
#' \code{write_output()} function) is behaving internally.
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
#' @section Parameter \code{label} vs. parameter \code{caption}:
#'
#' The difference between the \code{label} and \code{caption} is that label has
#' a special role in the document it is sent to. In a \code{.docx} document, it
#' will be a header at the top of a page. Visually, that will make it look more
#' like a title. It has the additional benefit of being automatically detectable
#' by MS Word's table of contents and other features. Likewise, \code{labels} in
#' \code{.xlsx} documents will serve as sheet names. Because \code{label} will
#' serve this titular role in both documents, it should ideally be short and
#' simply used to help the document recipient locate something for which the
#' reader might be searching.
#'
#' In contrast, the \code{caption} string is just plain text that will appear
#' either above (\code{.xlsx}) or below (\code{.docx}) the output itself. It is
#' suitable for much longer descriptions, capable of providing detail and
#' context to the reader.
#'
#' Note, neither \code{label} nor \code{caption} support anything other than
#' plain text (e.g., Rmarkdown).
#'
#'
#' @return (invisibly) The original, unmodified output object (\code{x})
#'
#' @family write_output-related functions
#'
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
#' my_outbox <- tempfile(fileext = '.xlsx')
#'
#' # starting with a blank output file (append = FALSE)
#' write_output(tbl_1, my_outbox, label = 'Drug trial results', append = FALSE)
#'
#' tbl_2 <- mtcars |>
#'   lm(mpg ~ cyl + wt, data = _) |>
#'   tbl_regression()
#'
#' # add an additional table to that same path, with append = TRUE
#' write_output(tbl_2, my_outbox, label = FALSE, append = TRUE)
#' @order 1
write_output <- function(x, path = NULL, label = FALSE, caption = NULL,
                         append = TRUE, ...) {

  if (is.null(path)) {

    if (is.null(last_path())) {
      stop('No path provided and no last path stored.')
    }

    path <- last_path()

  }

  assign('last_path', value = path, envir = outbox_env)

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


