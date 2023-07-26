gtsummary_to_docx <- function(gtsummary_tbl, path, add_date = TRUE, overwrite = FALSE) {

  if(!file.exists(path)){
    word_doc <- officer::read_docx() %>%
      body_add_par(
        value = 'Title Page', # TODO add some title page handling,
        style = 'heading 1')

    print(word_doc, target = path)
  }

  word_doc <- path %>%
    officer::read_docx() %>%
    officer::body_add_break()

  flex_tbl <- gtsummary_tbl %>%
    gtsummary::as_flex_table()

  word_doc <- word_doc %>%
    flextable::body_add_flextable(flex_tbl)

  print(word_doc, target = path)

  invisible(gtsummary_tbl)
}
