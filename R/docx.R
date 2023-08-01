#' Create an empty Word Document (docx)
#'
#' This function creates an empty Word Document (docx) at the specified path. It is designed
#' to be used internally for initializing docx files before adding content or sections.
#'
#' @param path The file path where the Word Document (docx) will be created.
#'
#' @param toc Logical, indicating whether to include a Table of Contents (TOC) in the
#'            created document. The default is TRUE.
#'
#' @details This function creates an empty Word Document (docx) and returns the document
#' object, which can be used to add content, paragraphs, sections, or Table of Contents (TOC).
#' By default, a Table of Contents (TOC) is included in the document.
#'
#' @return An invisible Word Document (docx) object representing the empty Word Document.
#'
#' @examples
#'
#' # Create an empty Word Document (docx) named 'example.docx'
#' outbox:::create_docx('example.docx')
#'
#' # Create an empty Word Document (docx) with Table of Contents (TOC) disabled
#' outbox:::create_docx('example_without_toc.docx', toc = FALSE)
#'
#' @keywords internal
#'
#' @family docx-related functions
#'
create_docx <- function(path, toc = TRUE) {
  word_doc <- officer::read_docx() |>
    officer::body_add_par(
      value = 'Title Page', # TODO add some title page handling,
      style = 'centered')

  if (toc) {
    word_doc <- word_doc |>
      officer::body_add_par(' ') |>
      officer::body_add_par(' ') |>
      officer::body_add_toc()
  }

  # With package officer, this saves the file to the path
  print(word_doc, target = path)

  invisible(word_doc)
}



#' Append Caption to Word Document
#'
#' This function appends a caption to a Word document. It is designed to be used
#' internally by docx-specific export functions (e.g., \code{ggplot_to_docx})
#'
#' @param word_doc The Word document object to which the caption will be
#'                appended.
#'
#' @param caption A character vector containing the caption text to be appended
#'                to the Word document. If NULL or not provided, no caption will
#'                be appended.
#'
#' @return The modified Word document object with the caption appended (if
#'         provided) or the original Word document object if no caption is
#'         provided.
#'
#' @family docx-related functions
#'
#' @examples
#' # Example of internal call that might be made by ggplot_to_docx()
#' caption <- 'This is a sample caption.'
#' word_doc <- officer::read_docx() |>
#'   outbox:::append_caption_docx(caption)
append_caption_docx <- function(word_doc, caption){
  if (!is.null(caption)){
    word_doc <- word_doc |>
      officer::body_add_par(' ') |>
      officer::body_add_par(' ') |>
      officer::body_add_par(caption, style = 'Normal')
  }

  word_doc
}



#' @rdname write_output
#' @family docx-related functions
#' @export
gtsummary_to_docx <- function(
    x, path, label = FALSE, caption = NULL, append = TRUE, toc = TRUE,
    update_fields = FALSE) {

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

  flex_tbl <- gtsummary::as_flex_table(x)

  word_doc <- word_doc |>
    officer::body_add_break() |>
    officer::body_add_par(value = label, style = 'heading 1') |>
    officer::body_add_par(' ') |>
    officer::body_add_par(' ') |>
    flextable::body_add_flextable(flex_tbl) |>
    append_caption_docx(caption = caption)

  # package officer saves word_doc to path
  print(word_doc, target = path)

  if (update_fields){
    # attempts to refresh things like the table of contents
    # doconv package requires MS Word to be installed on local machine to work
    doconv::docx_update(input = path)
  }

  invisible(x)
}



#' @rdname write_output
#' @family docx-related functions
#' @export
ggplot_to_docx <- function(
    x, path, label = FALSE, caption = NULL, append = TRUE, toc = TRUE,
    update_fields = FALSE, height = 5, width = 6, res = 300) {

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

  word_doc <- word_doc |>
    officer::body_add_break() |>
    officer::body_add_par(value = label, style = 'heading 1') |>
    officer::body_add_par(' ') |>
    officer::body_add_par(' ') |>
    officer::body_add_gg(
      value = x,
      width = width,
      height = height,
      res = res) |>
    append_caption_docx(caption = caption)

  # package officer saves word_doc to path
  print(word_doc, target = path)

  if (update_fields){
    # attempts to refresh things like the table of contents
    # doconv package requires MS Word to be installed on local machine to work
    doconv::docx_update(input = path)
  }

  invisible(x)
}


#' @rdname write_output
#' @family docx-related functions
#' @export
flextable_to_docx <- function(
    x, path, label = FALSE, caption = NULL, append = TRUE, toc = TRUE,
    update_fields = FALSE) {

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

  word_doc <- word_doc |>
    officer::body_add_break() |>
    officer::body_add_par(value = label, style = 'heading 1') |>
    officer::body_add_par(' ') |>
    officer::body_add_par(' ') |>
    flextable::body_add_flextable(x) |>
    append_caption_docx(caption = caption)

  # package officer saves word_doc to path
  print(word_doc, target = path)

  if (update_fields){
    # attempts to refresh things like the table of contents
    # doconv package requires MS Word to be installed on local machine to work
    doconv::docx_update(input = path)
  }

  invisible(x)
}




