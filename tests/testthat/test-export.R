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
      hp = c(110, 110, 93, 93))

    p <- ggplot(data, aes(x = mpg, y = hp)) + geom_point()

    path <- 'output.txt'

    # call construct_output_function with an unsupported output extension
    expect_error(construct_output_function(p, path))
})

test_that('write_output correctly writes gtsummary table to xlsx', {

  # create a sample gtsummary table and a path with xlsx extension
  library(gtsummary)

  data <- data.frame(
    Group = c('A', 'A', 'B', 'B'),
    Value = c(10, 20, 15, 25))

  tbl <- tbl_summary(data)

  path <- tempfile(fileext = '.xlsx')

  # call write_output to write the gtsummary table to xlsx
  result <- write_output(tbl, path)

  # check if the file is created and contains the table
  expect_true(file.exists(path))
})

test_that('write_output correctly writes ggplot to docx', {

  # create a sample ggplot object and a path with docx extension
  library(ggplot2)

  data <- data.frame(
    mpg = c(21, 21, 22, 22),
    hp = c(110, 110, 93, 93))

  p <- ggplot(data, aes(x = mpg, y = hp)) + geom_point()
  path <- tempfile(fileext = '.docx')

  # call write_output to write the ggplot to docx
  result <- write_output(p, path)

  # check if the file is created and contains the plot
  expect_true(file.exists(path))
})

test_that('write_output throws an error for unsupported output type', {

  # create an unsupported output type (data.frame in this case) and a path with
  # xlsx extension
  data <- data.frame(
    Group = c('A', 'A', 'B', 'B'),
    Value = c(10, 20, 15, 25)
  )
  path <- tempfile(fileext = '.xlsx')

  # call write_output with an unsupported output type
  expect_error(write_output(data, path))
})

test_that('write_output throws an error for unsupported output extension', {

  # create a sample ggplot object and a path with an unsupported extension
  # (txt in this case)
  library(ggplot2)
  data <- data.frame(
    mpg = c(21, 21, 22, 22),
    hp = c(110, 110, 93, 93)
  )
  p <- ggplot(data, aes(x = mpg, y = hp)) + geom_point()
  path <- tempfile(fileext = '.txt')

  # call write_output with an unsupported output extension
  expect_error(write_output(p, path))
})

test_that('write_output correctly assigns a new last_path', {

  # create a sample gtsummary table and a new path with xlsx extension
  library(gtsummary)

  data <- data.frame(
    Group = c('A', 'A', 'B', 'B'),
    Value = c(10, 20, 15, 25))
  tbl <- tbl_summary(data)
  new_path <- tempfile(fileext = '.xlsx')

  # call write_output to write the gtsummary table to the new path
  result <- write_output(tbl, new_path)

  # check if the new path is assigned as the last_path
  expect_equal(last_path(), new_path)
})


test_that(
  desc = 'write_output throws error when no path given and no last_path stored',
  code = {

    # create a sample gtsummary table
    library(gtsummary)

    data <- data.frame(
      Group = c('A', 'A', 'B', 'B'),
      Value = c(10, 20, 15, 25))

    tbl <- tbl_summary(data)

    # ensure no last path is stored in package environment
    assign('last_path', value = NULL, envir = outbox:::outbox_env)

    # call write_output without providing a path and no last_path stored
    expect_error(write_output(tbl))
})

test_that('write_output correctly uses the last_path when no path provided', {

  # create a sample gtsummary table and set a last_path
  library(gtsummary)

  data <- data.frame(
    Group = c('A', 'A', 'B', 'B'),
    Value = c(10, 20, 15, 25))

  tbl <- tbl_summary(data)
  last_path <- tempfile(fileext = '.xlsx')

  # ensure a last path is stored in package environment
  assign('last_path', value = last_path, envir = outbox:::outbox_env)

  # call write_output without providing a path
  result <- write_output(tbl)

  # check if the table is written to the last_path
  expect_true(file.exists(last_path))
})

test_that('write_output correctly uses the provided path', {
  # create a sample gtsummary table and a new path with xlsx extension
  library(gtsummary)

  data <- data.frame(
    Group = c('A', 'A', 'B', 'B'),
    Value = c(10, 20, 15, 25))

  tbl <- tbl_summary(data)
  new_path <- tempfile(fileext = '.xlsx')

  assign('last_path', value = 'distraction_path.xlsx', envir = outbox_env)

  # call write_output with a new path
  result <- write_output(tbl, path = new_path)

  # check if the table is written to the new path
  expect_true(file.exists(new_path))
})

test_that('write_output wont throw an error when label is supplied', {

  # create a sample gtsummary table and a path with xlsx extension

  library(gtsummary)
  data <- data.frame(
    Group = c('A', 'A', 'B', 'B'),
    Value = c(10, 20, 15, 25))

  tbl <- tbl_summary(data)
  path <- tempfile(fileext = '.xlsx')

  # call write_output with a label supplied
  result <- write_output(tbl, path, label = 'My Table')

  expect_no_error(result)
})

test_that('write_output wont throw an error when caption is supplied', {

  # create a sample gtsummary table and a path with xlsx extension
  library(gtsummary)
  data <- data.frame(
    Group = c('A', 'A', 'B', 'B'),
    Value = c(10, 20, 15, 25))

  tbl <- tbl_summary(data)
  path <- tempfile(fileext = '.xlsx')

  # call write_output with a caption supplied
  result <- write_output(tbl, path, caption = 'This is a sample table')
  expect_no_error(result)
})

test_that(
  desc = 'write_output wont throw an error when it has both label and caption',
  code = {

    # Create a sample gtsummary table and a path with xlsx extension
    library(gtsummary)
    data <- data.frame(
      Group = c('A', 'A', 'B', 'B'),
      Value = c(10, 20, 15, 25))

    tbl <- tbl_summary(data)
    path <- tempfile(fileext = '.xlsx')

    # Call write_output with both label and caption supplied
    result <- write_output(
      x = tbl,
      path = path,
      label = 'My Table',
      caption = 'This is a sample table')

    expect_no_error(result)
})


