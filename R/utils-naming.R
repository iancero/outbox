

#' Append today's date to the end of a file path
#'
#' @param path The file path string (including file name and extension) to which the
#' current date should be appended.
#'
#' @return A modified string filepath with the date added (just before the
#' file extension at the end).
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
