
#' @export
makeRLearner.regr.ranger = function() {

  makeRLearnerRegr(
    cl = "regr.ranger",
    package = "ranger",
    par.set = makeParamSet(
      makeIntegerLearnerParam(id = "num.trees", lower = 1L, default = 500L),
      makeIntegerLearnerParam(id = "mtry", lower = 1L),
      makeIntegerLearnerParam(id = "min.node.size", lower = 1L, default = 5L),
      makeLogicalLearnerParam(id = "replace", default = TRUE),
      makeNumericLearnerParam(id = "sample.fraction", lower = 0L, upper = 1L),
      makeNumericVectorLearnerParam(id = "split.select.weights", lower = 0, upper = 1),
      makeUntypedLearnerParam(id = "always.split.variables"),
      makeDiscreteLearnerParam("respect.unordered.factors", values = c("ignore", "order", "partition"), default = "ignore"),
      makeDiscreteLearnerParam(id = "importance", values = c("none", "impurity", "permutation"), default = "none", tunable = FALSE),
      makeLogicalLearnerParam(id = "write.forest", default = TRUE, tunable = FALSE),
      makeLogicalLearnerParam(id = "scale.permutation.importance", default = FALSE, requires = quote(importance == "permutation"), tunable = FALSE),
      makeIntegerLearnerParam(id = "num.threads", lower = 1L, when = "both", tunable = FALSE),
      makeLogicalLearnerParam(id = "save.memory", default = FALSE, tunable = FALSE),
      makeLogicalLearnerParam(id = "verbose", default = TRUE, when = "both", tunable = FALSE),
      makeIntegerLearnerParam(id = "seed", when = "both", tunable = FALSE),
      makeDiscreteLearnerParam(id = "splitrule", values = c("variance", "extratrees", "maxstat"), default = "variance"),
      makeIntegerLearnerParam(id = "num.random.splits", lower = 1L, default = 1L, requires = quote(splitrule == "extratrees")),
      makeNumericLearnerParam(id = "alpha", lower = 0L, upper = 1L, default = 0.5, requires = quote(splitrule == "maxstat")),
      makeNumericLearnerParam(id = "minprop", lower = 0, upper = 0.5, default = 0.1, requires = quote(splitrule == "maxstat")),
      makeLogicalLearnerParam(id = "keep.inbag", default = FALSE, tunable = FALSE)
    ),
    par.vals = list(num.threads = 1L, verbose = FALSE, respect.unordered.factors = "order"),
    properties = c("numerics", "factors", "ordered", "oobpreds", "featimp", "se", "weights"),
    name = "Random Forests",
    short.name = "ranger",
    note = "By default, internal parallelization is switched off (`num.threads = 1`), `verbose` output is disabled, `respect.unordered.factors` is set to `order` for all splitrules.",
    callees = "ranger"
  )
}

#' @export
trainLearner.regr.ranger = function(.learner, .task, .subset, .weights = NULL, ...) {

  tn = getTaskTargetNames(.task)
  ranger::ranger(formula = NULL, dependent.variable = tn, data = getTaskData(.task, .subset),
    case.weights = .weights, ...)
}

#' @export
predictLearner.regr.ranger = function(.learner, .model, .newdata, ...) {

  type = if (.learner$predict.type == "se") "se" else "response"
  p = predict(object = .model$learner.model, data = .newdata, type = type, ...)
  if (.learner$predict.type == "se") {
    return(cbind(p$predictions, p$se))
  } else {
    return(p$predictions)
  }
}

#' @export
getOOBPredsLearner.regr.ranger = function(.learner, .model) {

  getLearnerModel(.model, more.unwrap = TRUE)$predictions
}

#' @export
getFeatureImportanceLearner.regr.ranger = function(.learner, .model, ...) {

  getFeatureImportanceLearner.classif.ranger(.learner, .model, ...)
}
