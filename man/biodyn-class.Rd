\name{biodyn-class}
\Rdversion{1.1}
\docType{class}
\alias{biodyn-class}
\alias{biodyns,biodyn-method}
\alias{bmsy,biodyn,missing-method}
\alias{computeSP,biodyn,FLQuant-method}
\alias{computeSP,biodyn,missing-method}
\alias{computeSP,biodyn,numeric-method}
\alias{fit,biodyn,FLQuant-method}
\alias{fmsy,biodyn,missing-method}
\alias{fwd,biodyn,FLQuants-method}
\alias{fwd,biodyn,list-method}
\alias{fwd,biodyn,missing-method}
\alias{hcr,biodyn-method}
\alias{hcrPlot,biodyn-method}
\alias{kobePhase,biodyn-method}
\alias{msy,biodyn,missing-method}
\alias{plot,biodyn,missing-method}
\alias{power,biodyn,biodyn-method}
\alias{power,biodyn,missing-method}
\alias{profile,biodyn-method}
\alias{refpts,biodyn,missing-method}
\alias{setControl<-,biodyn,FLPar-method}
\alias{setParams<-,biodyn,data.frame-method}
\alias{setParams<-,biodyn,FLPar-method}
\alias{setParams<-,biodyn,FLQuant-method}
\alias{setParams<-,biodyn,FLQuants-method}
\alias{tac,biodyn-method}

\title{Class \code{"biodyn"}}
\description{
Implements a biomass dynamic model class
}
\section{Objects from the Class}{
Objects can be created by calls of the form \code{new("biodyn", ...)}. Each slot has an accessor so that rather than accessing in directly, e.g. \code{object@catch}
it is read \code{catch(object)} or written to \code{catch(object)<-} via a method which allows for validation and protecting a user from the raw objects.
}
\section{Slots}{
  \describe{
    \item{\code{model}:}{\code{"factor"} specifies the form of the surplus production function, so far the only option is for the Pella-Tomlinson i.e. \code{pellat}.}
    \item{\code{name}:}{\code{"character"} that identifies the run.}
    \item{\code{desc}:}{\code{"character"} that provides a brief summary of the object.}
    \item{\code{range}:}{ \code{"numeric"} vector containing the dimensions of the object.}
    \item{\code{catch}:}{\code{"FLQuant"} with catch time series.}
    \item{\code{stock}:}{\code{"FLQuant"} with estimated stock time series.}
    \item{\code{params}:}{\code{"FLPar"} with parameter estimates.}
    \item{\code{control}:}{\code{"FLPar"} with \code{phase,min,val,max} for each parameter.}
    \item{\code{priors}:}{\code{"FLPar"} that allows priors to be set for each parameter.}
    \item{\code{vcov}:}{\code{"FLPar"} with variance covariance matrix.}
    \item{\code{hessian}:}{\code{"FLPar"} with hessian.}
  }
}
\section{Extends}{
Class \code{"\linkS4class{FLComp}"}, directly.
}
\\
\section{Methods}{
  \describe{
    \item{biodyns}{\code{signature(object = "biodyn")}: ... }
    \item{bmsy}{\code{signature(object = "biodyn", params = "missing")}: ... }
    \item{computeSP}{\code{signature(object = "biodyn", biomass = "FLQuant")}: ... }
    \item{computeSP}{\code{signature(object = "biodyn", biomass = "missing")}: ... }
    \item{computeSP}{\code{signature(object = "biodyn", biomass = "numeric")}: ... }
    \item{fit}{\code{signature(object = "biodyn", index = "FLQuant")}: ... }
    \item{fmsy}{\code{signature(object = "biodyn", params = "missing")}: ... }
    \item{fwd}{\code{signature(object = "biodyn", ctrl = "FLQuants")}: ... }
    \item{fwd}{\code{signature(object = "biodyn", ctrl = "list")}: ... }
    \item{fwd}{\code{signature(object = "biodyn", ctrl = "missing")}: ... }
    \item{hcr}{\code{signature(object = "biodyn")}: ... }
    \item{hcrPlot}{\code{signature(object = "biodyn")}: ... }
    \item{kobePhase}{\code{signature(object = "biodyn")}: ... }
    \item{msy}{\code{signature(object = "biodyn", params = "missing")}: ... }
    \item{plot}{\code{signature(x = "biodyn", y = "missing")}: ... }
    \item{power}{\code{signature(object = "biodyn", ref = "biodyn")}: ... }
    \item{power}{\code{signature(object = "biodyn", ref = "missing")}: ... }
    \item{profile}{\code{signature(fitted = "biodyn")}: ... }
    \item{refpts}{\code{signature(object = "biodyn", params = "missing")}: ... }
    \item{setControl<-}{\code{signature(object = "biodyn", value = "FLPar")}: ... }
    \item{setParams<-}{\code{signature(object = "biodyn", value = "data.frame")}: ... }
    \item{setParams<-}{\code{signature(object = "biodyn", value = "FLPar")}: ... }
    \item{setParams<-}{\code{signature(object = "biodyn", value = "FLQuant")}: ... }
    \item{setParams<-}{\code{signature(object = "biodyn", value = "FLQuants")}: ... }
    \item{tac}{\code{signature(object = "biodyn")}: ... }
}}
\\
\author{
Laurence Kell

Maintainer: Laurence Kell <laurie.kell@iccat.int>
}

\examples{
showClass("biodyn")
}
\keyword{classes}
