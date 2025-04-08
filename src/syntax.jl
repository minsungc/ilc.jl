# Types

abstract type Type end

mutable struct TVar <: Type
    name::Symbol
end

struct TSum <: Type
    inr::Type
    inl::Type
end

struct TProd <: Type
    left::Type
    right::Type
end

struct TMu <: Type
    binder::Symbol
    rest::Type
end

mk_var(e) = TVar(e)
mk_tsum(l,r) = TSum(l,r)
mk_tprod(l,r) = TProd(l,r)
mk_tmu(b,e) = TMu(b,e)

macro type(e)
    return _expr_to_type(e)
end

function _expr_to_type(e)
    if e isa Symbol return mk_var(e) end
    @match e.head begin
        :. => begin
            b = e.args[1]
            expr = e.args[2]
            @match expr begin
                ::QuoteNode => return mk_tmu(b, _expr_to_type(eval(expr))) # idk the parser's weird
                ::Expr      => return mk_tmu(b, _expr_to_type(expr.args[1])) # idk the parser's weird
            end
        end
        :call => begin
            op = e.args[1]
            l = e.args[2]
            r = e.args[3]
            @match op begin
                :+ => return mk_tsum(_expr_to_type(l), _expr_to_type(r))
                :* => return mk_tprod(_expr_to_type(l), _expr_to_type(r))
            end
        end
    end
end
