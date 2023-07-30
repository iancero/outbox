test_that(
  desc = 'append_date() appends dates correctly to file paths',
  code = {
    old_path <- 'my_dir/file_name.ext'
    today <- as.character(Sys.Date())
    new_path <- append_date(old_path)

    # is today now in the path?
    expect_match(object = new_path, today)

    # is today in the right place - after the name, but before the extension?
    expect_equal(
      object = stringr::str_split_1(new_path, today),
      expected = c('my_dir/file_name_', '.ext'))
    }
)
