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


write_output <- function(x, path, label, add_date = TRUE, append = TRUE, ...) {
  dot_args <- rlang::list2(...)
  output_func <- construct_output_function(x, path)



  rlang::exec(
    .fn = output_func,
    x,
    path = path,
    label = label,
    add_date = add_date,
    append = append,
    !!!dot_args)
}
