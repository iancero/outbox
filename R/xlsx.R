create_xlsx <- function(path) {
  output_wb <- openxlsx::createWorkbook(creator = 'user')

  # TODO: create default title sheet and add into document

  openxlsx::saveWorkbook(output_wb, file = path, overwrite = TRUE)

  invisible(output_wb)
}




#' @rdname write_output
#' @export
gtsummary_to_xlsx <- function(x, path, label = FALSE, append = TRUE) {

  if(append == FALSE){
    # delete existing file, so a new one can be created below
    # if file doesn't exist, file.remove throws a warning, this is suppressed
    suppressWarnings(file.remove(path))
  }

  if(!file.exists(path)){
    output_wb <- openxlsx::createWorkbook(creator = 'user')
  } else {
    output_wb <- openxlsx::loadWorkbook(path)
  }

  if(label == F){
    label <- paste('Sheet', length(output_wb$sheet_names) + 1)
  }

  hux_tbl <- gtsummary::as_hux_table(x)

  huxtable::as_Workbook(
    ht = hux_tbl,
    Workbook = output_wb,
    sheet = label,
    write_caption = T)

  openxlsx::saveWorkbook(output_wb, file = path, overwrite = TRUE)

  invisible(x)
}






#' @rdname write_output
#' @export
ggplot_to_xlsx <- function(
    x, path, label = FALSE, append = FALSE, width = 6, height = 5, res = 300) {

  # TODO: Add support for an image caption (in text, not the image)

  if(append == FALSE){
    # delete existing file, so a new one can be created below
    # if file doesn't exist, file.remove throws a warning, this is suppressed
    suppressWarnings(file.remove(path))
  }

  if(file.exists(path) == FALSE){
    output_wb <- create_xlsx(path)
  } else {
    output_wb <- openxlsx::loadWorkbook(path)
  }

  if(label == F){
    label <- paste('Sheet', length(output_wb$sheet_names) + 1)
  }

  openxlsx::addWorksheet(wb = output_wb, sheetName = label)

  # save a temporary image file and keep track of its path
  plt_file <- ggplot2::ggsave(
    plot = x,
    filename = tempfile(fileext = '.png'),
    width = width,
    height = height,
    dpi = res)

  # insert image into the newly created sheet (not compatible with %>%)
  openxlsx::insertImage(
    wb = output_wb,
    file = plt_file,
    sheet = label,
    width = width,
    height = height,
    dpi = res)

  # save active workbook file
  openxlsx::saveWorkbook(output_wb, file = path, overwrite = TRUE)

  # delete the temporary file
  file.remove(plt_file)

  invisible(x)
}



