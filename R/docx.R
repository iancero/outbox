create_docx <- function(path, toc = TRUE) {
  word_doc <- officer::read_docx() %>%
    officer::body_add_par(
      value = 'Title Page', # TODO add some title page handling,
      style = 'heading 1')

  if (toc) {
    word_doc <- word_doc %>%
      officer::body_add_toc()
  }

  # With package officer, this saves the file to the path
  print(word_doc, target = path)

  invisible(word_doc)
}




gtsummary_to_docx <- function(
    gtsummary_tbl, path, label, add_date = TRUE, append = TRUE, toc = TRUE,
    update_fields = FALSE) {

  # TODO: change first argument to x (and in docs)

  if(add_date){
    path <- append_date(path)
  }

  if(append == FALSE){
    # delete existing file, so a new one can be created below
    # if file doesn't exist, file.remove throws a warning, this is suppressed
    suppressWarnings(file.remove(path))
  }

  if (file.exists(path) == FALSE) {
    word_doc <- create_docx(path, toc = toc)
  } else {
    word_doc <- officer::read_docx(path)
  }

  if (label == FALSE){
    label <- 'Table'
  }

  flex_tbl <- gtsummary_tbl %>%
    gtsummary::as_flex_table()

  word_doc <- word_doc %>%
    officer::body_add_break() %>%
    officer::body_add_par(value = label, style = 'heading 1') %>%
    flextable::body_add_flextable(flex_tbl)

  # package officer saves word_doc to path
  print(word_doc, target = path)

  if (update_fields){
    # attempts to refresh things like the table of contents
    # doconv package requires MS Word to be installed on local machine to work
    doconv::docx_update(input = path)
  }

  invisible(gtsummary_tbl)
}




ggplot_to_docx <- function(
    plt, path, label, add_date = TRUE, append = TRUE, toc = TRUE,
    update_fields = FALSE, height = 5, width = 6, res = 300) {

  # TODO: change first argument to x (and in docs)

  if(add_date){
    path <- append_date(path)
  }

  if(append == FALSE){
    # delete existing file, so a new one can be created below
    # if file doesn't exist, file.remove throws a warning, this is suppressed
    suppressWarnings(file.remove(path))
  }

  if (file.exists(path) == FALSE) {
    word_doc <- create_docx(path, toc = toc)
  } else {
    word_doc <- officer::read_docx(path)
  }

  if (label == FALSE){
    label <- 'Plot'
  }

  word_doc <- word_doc %>%
    officer::body_add_break() %>%
    officer::body_add_par(value = label, style = 'heading 1') %>%
    officer::body_add_gg(
      value = plt,
      width = width,
      height = height,
      res = res)

  # package officer saves word_doc to path
  print(word_doc, target = path)

  if (update_fields){
    # attempts to refresh things like the table of contents
    # doconv package requires MS Word to be installed on local machine to work
    doconv::docx_update(input = path)
  }

  invisible(plt)
}




