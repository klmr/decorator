args = commandArgs(trailingOnly = TRUE)

exit = function (code = 0)
    quit(save = 'no', status = if (is.null(code)) 0 else code)
