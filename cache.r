box::use(
    klmr/decorator[...],
    klmr/fun[closure, match_call_defaults],
)

#' @export
box::use(.[`%@%`])

#' Make function cached
#'
#' Cache a function call’s result so that subsequent calls of the function with
#' the same arguments do not re-evaluate the function: the cached result is
#' returned instead.
#' @usage f = cache \%@@\% function (arglist) expr
#' @param f the function name
#' @param arglist empty or one or more name or \code{name=expression} terms
#' @param expr an expression
#' @format NULL
#' @examples
#' fib = cache %@@% function (n) if (n < 2L) 1L else fib(n - 1L) + fib(n - 2L)
#' fib1 = function (n) if (n < 2L) 1L else fib1(n - 1L) + fib1(n - 2L)
#'
#' system.time(fib(31L))
#' #   user  system elapsed
#' #  0.005   0.001   0.005
#' system.time(fib1(31L))
#' #   user  system elapsed
#' #  2.802   0.011   2.816
#' @export
cache = decorator %@% function (f) {
    cache = new.env()
    g = function (...) {
        call = match_call_defaults()
        args = call[-1]
        # Use a helper to evaluate all arguments in their proper scope.
        calling_args = `[[<-`(call, 1, function (...) list(...))
        args_hash = if (is.null(args)) '.' else
            paste(lapply(eval.parent(calling_args), hash), collapse = ', ')
        if (exists(args_hash, cache))
            cache[[args_hash]]
        else {
            call[[1]] = f
            result = eval.parent(call)
            cache[[args_hash]] <<- result
            result
        }
    }
    closure(formals(f), body(g), environment())
}

hash = function (obj) UseMethod('hash')

hash.default = function (obj) deparse(obj)

hash.environment = function (obj) hash(as.list(obj))

hash.NULL = function (obj) 'NULL'

hash.function = function (obj)
    paste(deparse(obj), capture.output(environment(obj)))
