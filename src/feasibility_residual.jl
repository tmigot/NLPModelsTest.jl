export FeasibilityResidual

# TODO: Extend to handle bounds
"""
A feasibility residual model is created from a NLPModel of the form

    min f(x)
    s.t c(x) = 0

by defining the function F(x) = c(x). If the problem has
bounds on the variables or more constraints, an error
is thrown.
"""
type FeasibilityResidual <: AbstractNLSModel
  meta :: NLPModelMeta
  nls_meta :: NLSMeta
  counters :: NLSCounters
  nlp :: AbstractNLPModel
end

function FeasibilityResidual(nlp :: AbstractNLPModel; name=nlp.meta.name)
  if !equality_constrained(nlp)
    if unconstrained(nlp)
      throw(ErrorException("Can't handle unconstrained problem"))
    else
      throw(ErrorException("Can't handle inequalities"))
    end
  end

  m, n = nlp.meta.ncon, nlp.meta.nvar
  # TODO: What is copied?
  meta = NLPModelMeta(n, x0=nlp.meta.x0, name=name, lvar=nlp.meta.lvar,
                      uvar=nlp.meta.uvar)
  nls_meta = NLSMeta(m, n)
  nls = FeasibilityResidual(meta, nls_meta, NLSCounters(), nlp)
  finalizer(nls, nlp -> finalize(nls.nlp))

  return nls
end

function residual(nls :: FeasibilityResidual, x :: AbstractVector)
  increment!(nls, :neval_residual)
  return cons(nls.nlp, x)
end

function residual!(nls :: FeasibilityResidual, x :: AbstractVector, Fx :: AbstractVector)
  increment!(nls, :neval_residual)
  return cons!(nls.nlp, x, Fx)
end

function jac_residual(nls :: FeasibilityResidual, x :: AbstractVector)
  increment!(nls, :neval_jac_residual)
  return jac(nls.nlp, x)
end

function jprod_residual(nls :: FeasibilityResidual, x :: AbstractVector, v :: AbstractVector)
  increment!(nls, :neval_jprod_residual)
  return jprod(nls.nlp, x, v)
end

function jprod_residual!(nls :: FeasibilityResidual, x :: AbstractVector, v :: AbstractVector, Jv :: AbstractVector)
  increment!(nls, :neval_jprod_residual)
  return jprod!(nls.nlp, x, v, Jv)
end

function jtprod_residual(nls :: FeasibilityResidual, x :: AbstractVector, v :: AbstractVector)
  increment!(nls, :neval_jtprod_residual)
  return jtprod(nls.nlp, x, v)
end

function jtprod_residual!(nls :: FeasibilityResidual, x :: AbstractVector, v :: AbstractVector, Jtv :: AbstractVector)
  increment!(nls, :neval_jtprod_residual)
  return jtprod!(nls.nlp, x, v, Jtv)
end

function hess_residual(nls :: FeasibilityResidual, x :: AbstractVector, i :: Int)
  increment!(nls, :neval_hess_residual)
  y = zeros(nls.nls_meta.nequ)
  y[i] = 1.0
  return hess(nls.nlp, x, obj_weight = 0.0, y=y)
end

function hprod_residual(nls :: FeasibilityResidual, x :: AbstractVector, i :: Int, v :: AbstractVector)
  increment!(nls, :neval_hprod_residual)
  y = zeros(nls.nls_meta.nequ)
  y[i] = 1.0
  return hprod(nls.nlp, x, v, obj_weight = 0.0, y=y)
end

function hprod_residual!(nls :: FeasibilityResidual, x :: AbstractVector, i :: Int, v :: AbstractVector, Hiv :: AbstractVector)
  increment!(nls, :neval_hprod_residual)
  y = zeros(nls.nls_meta.nequ)
  y[i] = 1.0
  return hprod!(nls.nlp, x, v, Hiv, obj_weight = 0.0, y=y)
end