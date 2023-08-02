#' Get Supported Output Object Classes and File Types
#'
#' This function returns the list of supported output object classes and file
#' types by the outbox R package. It can be used to query the supported classes
#' and extensions for the \code{write_output()} function.
#'
#' @param what A character string specifying what to retrieve. Possible values
#'   are "classes" and "extensions". If \code{what} is \code{NULL}, the function
#'   will return a list containing both supported classes and extensions.
#'
#' @return If \code{what} is \code{NULL}, the function returns a list containing
#'   two character vectors: \code{classes} and \code{extensions}, representing
#'   the supported output object classes and file extensions, respectively. If
#'   \code{what} is specified, the function will return the corresponding vector
#'   of supported classes or extensions.
#'
#' @examples
#' # Get the list of supported output classes and extensions
#' supported()
#'
#' # Get the supported output object classes
#' supported('classes')
#'
#' # Get the supported file extensions
#' supported('extensions')
#'
#' @export
supported <- function(what = NULL) {
  support_list <- list(
    classes = c('gtsummary', 'ggplot', 'flextable'),
    extensions = c('xlsx', 'docx'))

  if (is.null(what)) {
    return(support_list)
  }

  requested_sublist <- support_list[[what]]

  requested_sublist
}
