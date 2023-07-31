test_that('append_caption_docx() adds caption correctly when caption is provided', {
  library(officer)

  # Create a sample word document
  doc <- read_docx() |>
    body_add_par('This is a test document.')

  # Add a caption to the document
  caption_text <- 'Figure 1: Scatter plot'
  doc_with_caption <- append_caption_docx(doc, caption_text)

  docx_df <- docx_summary(doc_with_caption)

  # Is the caption in the document at all?
  expect_true(caption_text %in% docx_df$text)

  # Is the caption is in the correct location, two blocks after the first line?
  expect_equal(
    object = docx_df |>
      dplyr::filter(text == caption_text) |>
      dplyr::pull(doc_index),
    expected = 4)
})

test_that('append_caption_docx() does not add caption when caption is NULL', {
  library(officer)

  # Create a sample word document
  doc <- read_docx() |>
    body_add_par('This is a test document.')

  # Add a NULL caption to the document
  doc_with_null_caption <- append_caption_docx(doc, NULL)

  # Check if the document remains unchanged
  expect_equal(doc, doc_with_null_caption)
})
