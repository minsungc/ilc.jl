module ILC

using Match: @match

include("src/syntax.jl")
include("src/semantics.jl")

export @term

end