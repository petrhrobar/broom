#' @templateVar class garch
#' @template title_desc_tidy
#'
#' @param x A `garch` object returned by [tseries::garch()].
#' @template param_unused_dots
#'
#' @evalRd return_tidy(
#'   "term",
#'   "estimate",
#'   "std.error",
#'   "statistic",
#'   "p.value"
#' )
#'
#' @examples
#'
#' library(tseries)
#' library(broom)
#' library(tidyverse)
#' 
#' data(EuStockMarkets)
#' dax <- diff(log(EuStockMarkets))[,"DAX"]
#' dax.garch <- garch(dax)
#' 
#'
#'
#' glance(dax.garch)
#' tidy.garch(dax.garch, conf.int = T)
#' @aliases garch_tidiers
#' @export
#' @family garch tidiers
#' @seealso [tidy()], [tseries::garch()]
tidy.garch <- function(x, conf.int = FALSE, conf.level = .95, ...) {
  s <- summary(x)
  co <- s$coef
  nn <- c("estimate", "std.error", "statistic", "p.value")
  ret <- fix_data_frame(co, nn[1:ncol(co)])
  as_tibble(ret)

  if (conf.int){
      ci <- confint(x, level = conf.level)
      ci <- as_tibble(ci, rownames = "term")
      colnames(ci) <- c("term", "conf.low", "conf.high")
      ret <- dplyr::left_join(ret, ci, by = "term")
    }
  ret
  
}

#' @templateVar class garch
#' @template title_desc_tidy
#'
#' @param x A `garch` object returned by [tseries::garch()].
#' @param test Character specification of which hypothesis test to use. The
#'   `garch` function reports 2 hypothesis tests: Jarque-Bera to residuals
#'    and Box-Ljung to squared residuals.
#' @template param_unused_dots
#'
#' @evalRd return_glance(
#'   "statistic",
#'   "p.value",
#'   "method",
#'   "logLik",
#'   "AIC",
#'   "BIC",
#'   "nobs",
#'   parameter = "Parameter field in the htest, typically degrees of
#'     freedom."
#' )
#'
#' @export
#' @family garch tidiers
#' @seealso [glance()], [tseries::garch()], []
glance.garch <- function(x, test = c("box-ljung-test", "jarque-bera-test"), ...) {
  test <- rlang::arg_match(test)
  s <- summary(x)
  ret <- garch_glance_helper(s, test, ...)
  ret$logLik <- as.numeric(stats::logLik(x))
  ret$AIC <- stats::AIC(x)
  ret$BIC <- stats::BIC(x)
  ret$nobs <- stats::nobs(x)
  ret
}

garch_glance_helper <- function(x, test, ...) {
  ret <- if (test == "box-ljung-test") {
    glance.htest(x$l.b.test)
  } else {
    glance.htest(x$j.b.test)
  }
  as_tibble(ret)
}

