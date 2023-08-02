test_that('supported() returns the correct list of supported classes and extensions', {
  # Get the list of supported classes and extensions
  support_list <- supported()

  # Check if the returned object is a list
  expect_type(support_list, 'list')

  # Check if the list contains 'classes' and 'extensions' elements
  expect_true('classes' %in% names(support_list))
  expect_true('extensions' %in% names(support_list))

  # Check if the elements of the list are character vectors
  expect_type(support_list$classes, 'character')
  expect_type(support_list$extensions, 'character')

  # Check if the list of supported classes and extensions is not empty
  expect_gt(length(support_list$classes), 0)
  expect_gt(length(support_list$extensions), 0)
})

test_that('supported("classes") returns the correct vector of supported classes', {
  # Get the vector of supported classes
  supported_classes <- supported('classes')

  # Check if the returned object is a character vector
  expect_type(supported_classes, 'character')

  # Check if the vector is not empty
  expect_gt(length(supported_classes), 0)
})

test_that('supported("extensions") returns the correct vector of supported extensions', {
  # Get the vector of supported extensions
  supported_extensions <- supported('extensions')

  # Check if the returned object is a character vector
  expect_type(supported_extensions, 'character')

  # Check if the vector is not empty
  expect_gt(length(supported_extensions), 0)
})
