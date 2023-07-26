append_date <- function(path) {
  filename <- tools::file_path_sans_ext(path)
  extension <- tools::file_ext(path)

  path_with_date <- glue::glue('{filename}_{Sys.Date()}.{extension}')

  path_with_date
}
