# Terms

abstract type Term end

const ValidConstTypes = Union{Int, String, Bool}

mutable struct Var <: Term
    name::Symbol
    typ::DataType
end

struct Const <: Term
    val::ValidConstTypes
end

struct Lambda <: Term
    bound::Var
    body::Term
end

struct App <: Term
    fn::Term
    body::Term
end

_var(s) = Var(s, Any)
function _var(x::Symbol, y::Symbol)
    @match y begin
        :String => Var(x, String)
        :Int    => Var(x, Int)
        :Bool   => Var(x, Bool)
    end
end
_const(x) = Const(x)
_lam(x::Var, t) = Lambda(x, t)
_lam(x::Symbol, t) = Lambda(_var(x),t)
_app(f, x) = App(f, x)

# Parser
macro term(e)
    return _expr_to_term(e)
end

function _expr_to_term(e)
    if e isa Symbol return _var(e) end
    if e isa ValidConstTypes return _const(e) end
    @match e.head begin
        :block  =>  return _expr_to_term(e.args[2])
        :->     =>  return _lam(
                        _expr_to_term(e.args[1]),
                        _expr_to_term(e.args[2]),
                    )
        :(::)   =>  return  _var(e.args[1], e.args[2])
        :call   =>  return _app(
                        _expr_to_term(e.args[1]),
                        _expr_to_term(e.args[2]),
                    )
    end
end

macro withtypes(e)
    x = _expr_to_term(e)
    return find_types(x, Vector{Var}())
end

const Env = Vector{Var}
const empty_env = Vector{Var}()

function is_valid_env(e::Env)
    for v in e
        if !(v.typ isa ValidConstTypes) return false end
    end
    return true
end

function find(x::Symbol, env::Env)
    for e in env
        if e.name == x return e end
    end
    return nothing
end

function find_types(x::Term, e::Env)
    @match x begin
        Var(s, t)       =>
            begin
                if t isa ValidConstTypes
                    return x
                elseif isnothing(find(s, e))
                    return x
                else
                    return find(s,e)
                end
            end
        Const(v)        =>
            return x
        Lambda(s, t)    =>
            begin
                news = find_types(s, e)
                push!(e, news)
                return Lambda(news, find_types(t, e))
            end
        App(s, t)       =>
            return App(find_types(s, e), find_types(t,e))
    end
end