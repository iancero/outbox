#' Append today's date to the end of a file path
#'
#' @param path The file path string (including file name and extension) to which
#' the current date should be appended.
#'
#' @return A modified string filepath with the date added (just before the
#' file extension at the end).
#'
#' @details
#' When code is run multiple times, it is sometimes desireable to maintain its
#' previous output files, rather than overwriting them (e.g., to compare old vs.
#' new in the case of a bug). One way to facilitate that is to append the
#' current date to your outbox file path at the top of a document. That way,
#' if the code is run on a new day, nothing will be overwritten from the
#' previous day.
#'
#'
#' @export
#'
#' @examples
#'
#' my_path <- 'my_dir/my_file.xlsx'
#' append_date(my_path)
append_date <- function(path) {
  filename <- tools::file_path_sans_ext(path)
  extension <- tools::file_ext(path)

  path_with_date <- glue::glue('{filename}_{Sys.Date()}.{extension}')

  path_with_date
}


