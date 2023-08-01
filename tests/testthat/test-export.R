test_that('last_path returns NULL when no path has been used yet', {

  # ensure last_path is set to NULL in package environment
  assign('last_path', value = NULL, envir = outbox:::outbox_env)

  # call last_path when no path has been used yet, check that result is NULL
  expect_null(last_path())
})

test_that('last_path returns the last path, when it exists', {

  # set a path in the outbox_env
  path <- 'output_1.xlsx'
  assign('last_path', path, envir = outbox_env)

  # call last_path to retrieve the last path used, check result matches set path
  expect_equal(last_path(), path)
})

test_that('detect_output_type correctly detects gtsummary class', {
  # create a sample gtsummary table
  library(gtsummary)
  data <- data.frame(
    Group = c('A', 'A', 'B', 'B'),
    Value = c(10, 20, 15, 25)
  )
  tbl <- tbl_summary(data)

  # call detect_output_type to detect the class
  result <- detect_output_type(tbl)

  # check if the result matches the detected class
  expect_equal(result, 'gtsummary')
})

test_that('detect_output_type correctly detects ggplot class', {
  # create a sample ggplot object
  library(ggplot2)
  data <- data.frame(
    mpg = c(21, 21, 22, 22),
    hp = c(110, 110, 93, 93)
  )
  p <- ggplot(data, aes(x = mpg, y = hp)) + geom_point()

  # call detect_output_type to detect the class
  result <- detect_output_type(p)

  # check if the result matches the detected class
  expect_equal(result, 'ggplot')
})

test_that('detect_output_type throws an error for unsupported class', {
  # create an unsupported class (data.frame in this case)
  data <- data.frame(
    Group = c('A', 'A', 'B', 'B'),
    Value = c(10, 20, 15, 25)
  )

  # call detect_output_type with an unsupported class
  expect_error(detect_output_type(data))
})



test_that('detect_output_ext correctly detects xlsx extension', {
  # create a sample path with xlsx extension
  path <- 'example.xlsx'

  # call detect_output_ext to detect the extension
  result <- detect_output_ext(path)

  # check if the result matches the detected extension
  expect_equal(result, 'xlsx')
})

test_that('detect_output_ext correctly detects docx extension', {
  # create a sample path with docx extension
  path <- 'example.docx'

  # call detect_output_ext to detect the extension
  result <- detect_output_ext(path)

  # check if the result matches the detected extension
  expect_equal(result, 'docx')
})

test_that('detect_output_ext throws an error for unsupported extension', {
  # create a sample path with an unsupported extension (txt in this case)
  path <- 'example.txt'

  # call detect_output_ext with an unsupported extension
  expect_error(detect_output_ext(path))
})


test_that(
  desc = 'construct_output_function finds function name for gtsummary to xlsx',
  code = {
    # create a sample gtsummary table and a path with xlsx extension
    library(gtsummary)
    data <- data.frame(
      Group = c('A', 'A', 'B', 'B'),
      Value = c(10, 20, 15, 25)
    )
    tbl <- tbl_summary(data)
    path <- 'output.xlsx'

    # call construct_output_function to construct the function name
    result <- construct_output_function(tbl, path)

    # check if the result matches the constructed function name
    expect_equal(result, 'gtsummary_to_xlsx')
})

test_that(
  desc = 'construct_output_function finds function name for ggplot to docx',
  code = {
    # create a sample ggplot object and a path with docx extension
    library(ggplot2)
    data <- data.frame(
      mpg = c(21, 21, 22, 22),
      hp = c(110, 110, 93, 93)
    )
    p <- ggplot(data, aes(x = mpg, y = hp)) + geom_point()
    path <- 'output.docx'

    # call construct_output_function to construct the function name
    result <- construct_output_function(p, path)

    # check if the result matches the constructed function name
    expect_equal(result, 'ggplot_to_docx')
})

test_that(
  desc = 'construct_output_function throws error for unsupported output type',
  code = {
    # create an unsupported output type (data.frame in this case) and a path
    # with xlsx extension
    data <- data.frame(
      Group = c('A', 'A', 'B', 'B'),
      Value = c(10, 20, 15, 25)
    )
    path <- 'output.xlsx'

    # call construct_output_function with an unsupported output type
    expect_error(construct_output_function(data, path))
})

test_that(
  desc = 'construct_output_function throws error for unsupported extension',
  code = {
    # create a sample ggplot object and a path with an unsupported extension
    # (txt in this case)
    library(ggplot2)
    data <- data.frame(
      mpg = c(21, 21, 22, 22),
      hp = c(110, 110, 93, 93)
    )
    p <- ggplot(data, aes(x = mpg, y = hp)) + geom_point()
    path <- 'output.txt'

    # call construct_output_function with an unsupported output extension
    expect_error(construct_output_function(p, path))
})
