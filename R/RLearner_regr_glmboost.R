#' @export
makeRLearner.regr.glmboost = function() {

  makeRLearnerRegr(
    cl = "regr.glmboost",
    package = "mboost",
    par.set = makeParamSet(
      makeDiscreteLearnerParam(id = "family", default = "Gaussian", values = c("Gaussian", "Laplace",
        "Huber", "Poisson", "GammaReg", "NBinomial", "Hurdle", "custom.family")),
      # families 'Poisson', 'NBinomial' and 'Hurdle' are for count data
      makeUntypedLearnerParam(id = "custom.family.definition", requires = quote(family == "custom.family")),
      makeNumericVectorLearnerParam(id = "nuirange", default = c(0, 100), requires = quote(family %in% c("GammaReg", "NBinomial", "Hurdle"))),
      makeNumericLearnerParam(id = "d", requires = quote(family == "Huber")),
      makeIntegerLearnerParam(id = "mstop", default = 100L, lower = 1L),
      makeNumericLearnerParam(id = "nu", default = 0.1, lower = 0, upper = 1),
      makeDiscreteLearnerParam(id = "risk", values = c("inbag", "oobag", "none")),
      makeLogicalLearnerParam(id = "stopintern", default = FALSE),
      # 'risk' and 'stopintern' will be kept for completeness sake
      makeLogicalLearnerParam(id = "center", default = TRUE),
      makeLogicalLearnerParam(id = "trace", default = FALSE, tunable = FALSE)
    ),
    par.vals = list(),
    properties = c("numerics", "factors", "weights"),
    name = "Boosting for GLMs",
    short.name = "glmboost",
    callees = c("glmboost", "mboost_fit", "boost_control", "Gaussian", "Laplace",
      "Huber", "Poisson", "GammaReg", "NBinomial", "Hurdle")
  )
}

#' @export
trainLearner.regr.glmboost = function(.learner, .task, .subset, .weights = NULL, family = "Gaussian", nuirange = c(0, 100), d = NULL, custom.family.definition, mstop, nu, risk, trace, stopintern, ...) {

  ctrl = learnerArgsToControl(mboost::boost_control, mstop, nu, risk, trace, stopintern)
  data = getTaskData(.task, .subset)
  f = getTaskFormula(.task)
  family = switch(family,
    Gaussian = mboost::Gaussian(),
    Laplace = mboost::Laplace(),
    Huber = mboost::Huber(d),
    Poisson = mboost::Poisson(),
    GammaReg = mboost::GammaReg(nuirange = nuirange),
    NBinomial = mboost::NBinomial(nuirange = nuirange),
    Hurdle = mboost::Hurdle(nuirange = nuirange),
    custom.family = custom.family.definition
  )
  if (is.null(.weights)) {
    model = mboost::glmboost(f, data = data, control = ctrl, family = family, ...)
  } else {
    model = mboost::glmboost(f, data = data, control = ctrl, weights = .weights, family = family, ...)
  }
  model
}

#' @export
predictLearner.regr.glmboost = function(.learner, .model, .newdata, ...) {

  p = predict(.model$learner.model, newdata = .newdata, ...)
  return(as.vector(p))
}
