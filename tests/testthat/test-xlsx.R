test_that(
  desc = "append_caption_xlsx appends caption correctly when caption is provided",
  code = {
    library(openxlsx)

    # Create a sample workbook
    wb <- createWorkbook()
    sheet_name <- "Sheet1"

    # Add a sheet to the workbook
    addWorksheet(wb, sheetName = sheet_name)

    # Add a caption to the sheet
    caption_text <- "This is a sample caption."
    wb_with_caption <- append_caption_xlsx(wb, sheet_name, caption_text)

    # Read the sheet and check if the caption is added correctly
    sheet_data <- read.xlsx(
      xlsxFile = wb_with_caption,
      sheet = sheet_name,
      colNames = F,
      rowNames = F)

    expect_equal(sheet_data[1, 1], caption_text)
})

test_that("append_caption_xlsx does not add caption when caption is NULL", {
  library(openxlsx)

  # Create a sample workbook
  wb <- createWorkbook()
  sheet_name <- "Sheet1"

  # Add a sheet to the workbook
  addWorksheet(wb, sheetName = sheet_name)

  # Add a NULL caption to the sheet
  first_caption <- 'Example first caption'
  wb_without_second_caption <- wb |>
    append_caption_xlsx(sheet_name, caption = first_caption) |>
    append_caption_xlsx(sheet_name, caption = NULL)



  # Read the sheet and check if the first caption remains unchanged
  sheet_data <- read.xlsx(
    xlsxFile = wb_without_second_caption,
    sheet = sheet_name,
    colNames = F,
    rowNames = F)

  expect_equal(sheet_data[1, 1], first_caption)
})
