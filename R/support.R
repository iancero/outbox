supported <- function(what = NULL) {
  support_list <- list(
    classes = c('gtsummary', 'ggplot', 'flextable'),
    extensions = c('xlsx', 'docx'))

  if(is.null(what)){
    return(support_list)
  }

  requested_sublist <- support_list[[what]]

  requested_sublist
}
