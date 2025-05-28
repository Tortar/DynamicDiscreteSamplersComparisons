
using AliasTables

function initialize_ALIAS_TABLE(rng, N)
	al = AliasTable([abs(randn(rng)) for _ in 1:N])
	return al
end

static_samples_ALIAS_TABLE(rng, al, N) = rand(rng, al, N)