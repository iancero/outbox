#' Create an empty XLSX file
#'
#' This function creates an empty XLSX file at the specified path. It is designed
#' to be used internally for initializing XLSX files before adding data or sheets.
#'
#' @param path The file path where the XLSX file will be created.
#'
#' @details This function creates an empty XLSX file and returns the workbook
#' object, which can be used to add data or sheets to the file.
#'
#' @return An invisible workbook object representing the empty XLSX file.
#'
#' @keywords internal
#'
#' @family xlsx-related functions
#'
#' @examples
#' \dontrun{
#' # Create an empty XLSX file named 'example.xlsx'
#' outbox:::create_xlsx('example.xlsx')
#' }
#'
create_xlsx <- function(path) {

  # throws warning about empty workbook
  output_wb <- suppressWarnings(
    expr = openxlsx::createWorkbook(creator = 'user'))

  # TODO: create default title sheet and add into document

  openxlsx::saveWorkbook(output_wb, file = path, overwrite = TRUE)

  invisible(output_wb)
}



#' Append Caption to XLSX Sheet
#'
#' This function appends a caption to an XLSX sheet. It is designed to be used
#' internally by xlsx-related export functions (e.g., \code{ggplot_to_xlsx})
#'
#' @param output_wb The output workbook object to which the caption will be
#'                  appended.
#'
#' @param sheet_name A character string representing the name of the sheet to
#'                   which the caption will be appended.
#'
#' @param caption A character string containing the caption text to be appended
#'                to the sheet. If NULL or not provided, no caption will be
#'                appended.
#'
#' @return The modified output workbook object with the caption appended (if
#'         provided) or the original output workbook object if no caption is
#'         provided.
#'
#' @family xlsx-related functions
#'
#' @examples
#' # Example of internal call that might be made by ggplot_to_xlsx()
#' sheet_name <- 'Sheet1'
#' caption <- 'This is a sample caption.'
#'
#' # avoid using pipes with openxlsx
#' output_wb <- openxlsx::createWorkbook()
#' openxlsx::addWorksheet(output_wb, sheetName = sheet_name)
#'
#' output_wb <- outbox:::append_caption_xlsx(output_wb, sheet_name, caption)
#'
append_caption_xlsx <- function(output_wb, sheet_name, caption){
  if (!is.null(caption)){
    output_caption <- as.character(caption)

    openxlsx::writeData(
      wb = output_wb,
      sheet = sheet_name,
      x = as.character(caption),
      startCol = 1,
      startRow = 1)
  }

  output_wb
}


#' @rdname write_output
#' @family xlsx-related functions
#' @export
gtsummary_to_xlsx <- function(x, path, label = FALSE, caption = NULL,
                              append = TRUE) {

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

  output_wb <- huxtable::as_Workbook(
      ht = hux_tbl,
      Workbook = output_wb,
      sheet = label,
      write_caption = T,
      start_row = 5) |>
    append_caption_xlsx(sheet_name = label, caption = caption)

  openxlsx::saveWorkbook(output_wb, file = path, overwrite = TRUE)

  invisible(x)
}



#' @rdname write_output
#' @family xlsx-related functions
#' @export
ggplot_to_xlsx <- function(
    x, path, label = FALSE, caption = NULL, append = TRUE, width = 6,
    height = 5, res = 300) {

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

  # insert image into the newly created sheet (not compatible with |> or %>%)
  openxlsx::insertImage(
    wb = output_wb,
    file = plt_file,
    sheet = label,
    startRow = 5,
    width = width,
    height = height,
    dpi = res)

  # again, avoid using pipes with openxlsx
  output_wb <- append_caption_xlsx(
    output_wb = output_wb,
    sheet_name = label,
    caption = caption)

  # save active workbook file
  openxlsx::saveWorkbook(output_wb, file = path, overwrite = TRUE)

  # delete the temporary file
  file.remove(plt_file)

  invisible(x)
}
