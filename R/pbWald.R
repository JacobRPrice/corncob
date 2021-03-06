#' Parametric bootstrap Wald test
#'
#' @param mod an object of class \code{bbdml}
#' @param mod_null an object of class \code{bbdml}, should be nested within \code{mod}
#' @param B Integer. Defaults to \code{1000}. Number of bootstrap iterations.
#'
#' @return P-value from parametric bootstrap Wald test.
#'
#' @examples
#' \dontrun{
#' data(soil_phylo)
#' soil <- soil_phylo %>%
#' phyloseq::subset_samples(DayAmdmt %in% c(11,21)) %>%
#' tax_glom("Phylum")
#' mod1 <- bbdml(formula = OTU.1 ~ DayAmdmt,
#' phi.formula = ~ DayAmdmt,
#' data = soil)
#'
#' mod2 <- bbdml(formula = OTU.1 ~ 1,
#' phi.formula = ~ 1,
#' data = soil)
#' pbWald(mod1, mod2, B = 100)
#' }
#' @export
pbWald <- function(mod, mod_null, B = 1000) {
  tmp <- getRestrictionTerms(mod = mod, mod_null = mod_null)
  restrictions <- tmp$mu
  restrictions.phi <- tmp$phi
  t.observed <- try(waldchisq_test(mod, restrictions = restrictions, restrictions.phi = restrictions.phi), silent = TRUE)
  if (class(t.observed) == "try-error") {
    return(NA)
  }

  BOOT <- rep(NA, B)
  for (j in 1:B) {
    #print(j)
    BOOT[j] <- doBoot(mod = mod, mod_null = mod_null, test = "Wald")
  }
  perc.rank <- function(x, y) (1 + sum(stats::na.omit(y) >= x)) / (length(stats::na.omit(y)) + 1)
  p.val <- perc.rank(t.observed, BOOT)
  return(p.val)
}
