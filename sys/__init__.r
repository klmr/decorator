# Command line tools don’t want to clutter their output with unnecessary noise.
library = function (...)
    suppressMessages(base::library(...))

#' The command line arguments
args = commandArgs(trailingOnly = TRUE)

#' Quit the program
#'
#' @param code numeric exit code (default: \code{0})
exit = function (code = 0)
    quit(save = 'no', status = if (is.null(code)) 0 else code)

#' Execute the \code{entry_point} function defined by the caller
run = function (entry_point = main) {
    caller = parent.frame()
    caller_name = evalq(modules::module_name(), envir = caller)

    if (is.null(caller_name)) {
        if (class(substitute(entry_point)) == '{')
            exit(entry_point)

        exit(eval(substitute(main(), list(main = entry_point)), envir = caller))
    }
}
