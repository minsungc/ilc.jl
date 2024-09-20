abstract type Term end

struct Var <: Term
    name::Symbol
end

struct Lambda <: Term
    name::Symbol
    body::Term
end

struct App <: Term
    fn::Term
    body::Term
end

_var(s) = Var(s)
_lam(x, t) = Lambda(x, t)
_app(f, x) = App(f, x)

# Parser
macro term(e)
    return _expr_to_term(e)
end

function _expr_to_term(e)
    if e isa Symbol return _var(e) end
    @match e.head begin
        :block  =>  return _expr_to_term(e.args[2])
        :->     =>  return _lam(e.args[1], _expr_to_term(e.args[2]))
        :call   =>  return _app(
                        _expr_to_term(e.args[1]),
                        _expr_to_term(e.args[2])
                    )
    end
end