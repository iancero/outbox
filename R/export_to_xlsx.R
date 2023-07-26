#' Export a \code{gtsummary} table object to a \code{.xlsx} document
#'
#' Takes a \code{gtsummary} table object and exports it to to a \code{.xlsx}
#' document, using the \code{huxtable} and \code{openxlsx} libraries.
#'
#' @param gtsummary_tbl A table created with the \code{gtsummary} package.
#' @param path Path to the .xlsx document. If it does not yet exist, it will
#' be created.
#' @param sheet_name Name of the sheet this table will receive, once entered
#' into the \code{.xlsx} document. If \code{FALSE}, it will be labelled by its
#' sheet number in the resulting document (i.e., if the document already has
#' two sheets, this new table's sheet name will be "Sheet 3"). Note, this param
#' intentionally received no default, to make it difficult for the user to
#' quickly dump a bunch of tables into a .xlsx document. Although this is easy
#' to do at the time or export, it tends to make it much harder for the
#' recipient to understand what is happening in a large document. For that
#' reason, if the user truly wants the convenience, the need to declare it
#' explicitly by setting this param to \code{FALSE}.
#' @param add_date If \code{TRUE}, a date be appended to the end of the file
#' name (\code{path}) before export. For example, 'my_path.xlsx' will become
#' something like 'my_path_2020_01_25.xlsx' (using Sys.Date() for today's date).
#' @param overwrite If \code{TRUE}, existing file will be overwritten by
#' openxlsx::saveWorkbook() - which does the exportation already under the hood.
#' Note, under normal circumstances you actually want this to be \code{TRUE}
#' because the current function first loads any existing workbook into memory,
#' then adds a sheet to it, then exports. So, if your goal is to ADD the current
#' table to an existing sheet (which is usually the case), \code{overwrite}
#' should probably be set to \code{TRUE}.
#'
#' @details
#' In theory, this function doesn't do much more than the existing
#' \code{gtsummary::as_hux_xlsx()} function. It's major contribution is a more
#' convenient workflow, which allows you to have a single filepath that you can
#' keep adding sheets to as an analysis (e.g., .Rmd document) expands. It also
#' has some convenience arguments to enhance the workflow
#'
#'
#' @return (invisible) The original \code{gtsummary_tbl}
#' @export
#'
#' @examples
#' library(outbox)
#' library(gtsummary)
#'
#' tbl_1 <- trial %>%
#'   tbl_summary(include = c(age, grade, response)) %>%
#'   modify_caption('Table X. Here is a test caption')
#'
#' fit <- glm(response ~ age + stage, trial, family = binomial)
#' tbl_2 <- fit %>%
#'   tbl_regression(exponentiate = TRUE)
#'
#' # Create an output workbook
#' path <- 'my_output.xlsx'
#' gtsummary_to_xlsx(tbl_1, path, sheet_name = FALSE, overwrite = FALSE)
#'
#' # Add an additional table to that same path, with overwrite = TRUE
#' gtsummary_to_xlsx(tbl_2, path, sheet_name = FALSE, overwrite = TRUE)

gtsummary_to_xlsx <- function(gtsummary_tbl, path, sheet_name, add_date = TRUE, overwrite = FALSE) {


  # TODO: what if there is already a sheet named X?

  if(add_date){
    path <- path %>%
      stringr::str_replace('.xlsx', glue::glue('_{Sys.Date()}.xlsx'))
  }


  if(!file.exists(path)){
    output_wb <- openxlsx::createWorkbook(creator = 'user')
  } else {
    output_wb <- openxlsx::loadWorkbook(path)
  }

  if(sheet_name == F){
    sheet_name <- paste('Sheet', length(output_wb$sheet_names) + 1)
  }

  hux_tbl <- gtsummary_tbl %>%
    gtsummary::as_hux_table()

  huxtable::as_Workbook(
    ht = hux_tbl,
    Workbook = output_wb,
    sheet = sheet_name,
    write_caption = T)

  openxlsx::saveWorkbook(output_wb, file = path, overwrite = overwrite)

  invisible(gtsummary_tbl)
}
