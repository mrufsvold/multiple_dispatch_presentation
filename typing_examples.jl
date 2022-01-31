### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ ab32e710-735f-11ec-2417-bf20f0dda11f
begin
using YAML
using Dates
using DataFrames
end

# ╔═╡ be7771fb-19c2-43b7-8eff-f2f7af7fab36
md"""
## Ensure Type Stability at Function Borders
"""

# ╔═╡ 5ed9f3b6-4182-45c9-ae9e-435ade6ef682
function dumb_add(num1, num2)
	num1 + num2
end

# ╔═╡ 7cdbc12d-23d7-4c9a-8559-9019486bf901
function do_dumb_add()
	x = 3.0
	y = 4.0
	a = x > y ? 1 : x
	b = x > y ? 0 : y
	dumb_add(a, b)
end


# ╔═╡ e4c0ceb3-dcb0-4cf2-a203-9654808af92e
function do_slightly_less_dumb_add()
	x = 3.0
	y = 4.0
	a::Int64  = x > y ? 1 : x
	b::Int64  = x > y ? 0 : y
	dumb_add(a, b)
end

# ╔═╡ 146b8d51-cc90-412c-84a7-dae2d0d1d09b
md"""
## Don't Use General Containers
### Reading a config file without types
"""

# ╔═╡ ff92d7a8-53cc-46b2-9e06-205d2cbaccec
begin
cd("C:\\Users\\mrufsvold\\Projects\\multiple_dispatch_presentation")
config = YAML.load_file("config.yml")
end

# ╔═╡ e3ad99e1-7350-474d-8561-50fb1a3daecc
Dict(val => typeof(val) for val in values(config))

# ╔═╡ 05be1e42-8fc7-4abb-8b0e-620f1edb0251
typeof(config)

# ╔═╡ 46344934-cad7-42c2-8f2c-9d367c6634fc
md"""
### Typing our config
"""

# ╔═╡ 8846351d-5108-4f0b-8c85-c6c68a6b1a53
function simple_typed_config(path)
	config::Dict{String, Union{Float64, Date, Int64, String}} = YAML.load_file("config.yml")
	config
end

# ╔═╡ 51ed93f5-4cf2-4974-b966-55faaeca485d
typed_config = simple_typed_config("config.yml")

# ╔═╡ c80a7658-2562-4744-bff6-467815d99bc1
typeof(typed_config)

# ╔═╡ f13e3e21-e97d-4705-840b-df26e32616c6
md"""
## More Specified Typing
"""

# ╔═╡ 7f0cd2ba-d74b-48c1-8ef4-b2e37ecac80b
begin
	function get_param1(conf::Dict)
		conf["param1"]::String
	end

	function get_param2(conf::Dict)
		conf["param2"]::Int
	end
	# ...
end

# ╔═╡ 830448cd-23bf-469b-a5f0-8104d9ec4961
begin
	function do_thing_with_param1(val::String)
		# Very insteresting stuff with a string input
	end
	
	val = get_param1(config)
	
	do_thing_with_param1(val)
end

# ╔═╡ 483c4a28-8483-42e8-b894-9e91542cea64
md"""
## Specify Types For Structs
"""

# ╔═╡ 48cd757c-b2c3-45b4-b314-1a62af57e895
struct employee
	birthdate
	address
	years_in_position
end

# ╔═╡ ef40a8cd-55e0-4b57-9cba-11fa50284838
function update_years_in_position(e::employee, y)
	n = employee(e.birthdate, e.address, y)
	(n, typeof(n.years_in_position))
end

# ╔═╡ b5332544-2fa8-42d8-80b1-021fd36cafaf
micah = employee("1994-06-04", "123 Avenue Way", 0)

# ╔═╡ 3e968151-bce2-4af9-bf1b-cdfe0112a907
md"""
### Aaaaah! The type instability!!!!
We can do better...
"""

# ╔═╡ 186c6ed1-c938-4f5c-b9ee-a51ad283c3c5
struct employee_typed
	birthdate::String
	address::String
	years_in_position::Int64
end

# ╔═╡ 609cf04b-7874-466d-806f-12ebd80e1d7c
function update_years_in_position(e::employee_typed, y)
	n = employee_typed(e.birthdate, e.address, y)
	(n, typeof(n.years_in_position))
end

# ╔═╡ c7d68f3e-2e09-41cc-9f98-f50a7a567aad
many_micahs = [
	(micah, typeof(micah.years_in_position)),
	update_years_in_position(micah, 1.0),
	update_years_in_position(micah, "five"),
	update_years_in_position(micah, 1+2im)
]

# ╔═╡ b3a5183f-4c8f-48df-b094-cc688a070af2
micah_typed = employee_typed("1994-06-04", "123 Avenue Way", 0)

# ╔═╡ cdfca0b3-8b3c-4cb1-b2c5-cece147edbda
try_many_micahs = [
	(micah_typed, typeof(micah_typed.years_in_position)),
	update_years_in_position(micah_typed, 1.0),
	#update_years_in_position(micah_typed, "five"),
	#update_years_in_position(micah_typed, 1+2im)
]

# ╔═╡ 4a6876a3-857c-4d7c-8ffa-2d35bac59cd9
md"""
## Use Multiple Dispatch
Julia lets you define the same function name with different instructions for different sets of parameter types. This is a powerful tool!
	"""

# ╔═╡ 65cf4392-847d-4384-b36f-6925f281223d
function no_dispatch_days_since_new_year(d)
	if typeof(d) == String
		d = Date(d, dateformat"y-m-d")
	end
	
	new_years = Date("2022-01-01", dateformat"y-m-d")
	d - new_years
end
	

# ╔═╡ 304a0263-1a04-4d67-9e0f-33a753aa1b55
function days_since_new_year(d::Date)
	new_years = Date("2022-01-01", dateformat"y-m-d")
	d - new_years
end

# ╔═╡ ea069802-e118-4dea-ba8f-b6c3d877a876
function days_since_new_year(d::String)
	new_years = Date("2022-01-01", dateformat"y-m-d")
	Date(d, dateformat"y-m-d") - new_years
end

# ╔═╡ ac6bb46b-ea0a-43a9-bba4-57d930764d3a
date_df = DataFrame(
	"String_Dates" => ["2022-06-01", "2022-01-06"],
	"Date_Dates" => [Date("2022-01-20", dateformat"y-m-d"), Date("2022-07-20", dateformat"y-m-d")]
)

# ╔═╡ 0f14108e-64f0-4b21-b4f9-9929978af453
mapcols(x -> days_since_new_year.(x), date_df)

# ╔═╡ e90faa5d-af8b-4a4c-a5af-84eaf000839d
md"""
## Preparing Data for Efficient Dispatch
Dispatch is powerful, but you can give it a further boost by taking away decisions from it.
	"""

# ╔═╡ 56a3a697-4114-4b90-a94b-e66805a66fdd
heterogenous_vector::Vector{Any} = [
	"heterogenous",
	"data",
	25,
	2.3,
	[1,2,3],
	"another",
	2,
	12345
]

# ╔═╡ c202e08a-a347-4821-94d4-32636ad3bd06
begin
	# Create your variable outside the loop
	type_dict::Dict{DataType, Vector{Any}} = Dict()
	
	for x in heterogenous_vector
		# Make a vector for each type of data in the original
		if typeof(x) in keys(type_dict)
			push!(type_dict[typeof(x)], x)
		else
			type_dict[typeof(x)] = [x]
		end
	end
end

# ╔═╡ 2486d867-388d-4b50-ae34-c4a3f4f6e726
type_dict

# ╔═╡ ee5d4f11-72c7-4cd1-bb53-9945e26ab5fb
begin
	function make_a_string(v::String)
		v
	end
	function make_a_string(v::Number)
		string(v)
	end
	function make_a_string(v::Vector{Int64})
		join(make_a_string.(v), ", ")
	end
end

# ╔═╡ aec8a241-2901-4762-bb88-a7408e2e11d8
begin
	strings_vec::Vector{String} = []
	for (dtype, vec) in pairs(type_dict)
		typed_vec::Vector{dtype} = vec
		append!(strings_vec, make_a_string.(vec))
	end
	strings_vec
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
YAML = "ddb6d928-2868-570f-bddf-ab3f9cf99eb6"

[compat]
DataFrames = "~1.3.1"
YAML = "~0.4.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0"
manifest_format = "2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Crayons]]
git-tree-sha1 = "b618084b49e78985ffa8422f32b9838e397b9fc2"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.0"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "cfdfef912b7f93e4b848e80b9befdf9e331bc05a"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StringEncodings]]
deps = ["Libiconv_jll"]
git-tree-sha1 = "50ccd5ddb00d19392577902f0079267a72c5ab04"
uuid = "69024149-9ee7-55f6-a4c4-859efe599b68"
version = "0.3.5"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.YAML]]
deps = ["Base64", "Dates", "Printf", "StringEncodings"]
git-tree-sha1 = "3c6e8b9f5cdaaa21340f841653942e1a6b6561e5"
uuid = "ddb6d928-2868-570f-bddf-ab3f9cf99eb6"
version = "0.4.7"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═ab32e710-735f-11ec-2417-bf20f0dda11f
# ╟─be7771fb-19c2-43b7-8eff-f2f7af7fab36
# ╠═5ed9f3b6-4182-45c9-ae9e-435ade6ef682
# ╠═7cdbc12d-23d7-4c9a-8559-9019486bf901
# ╠═e4c0ceb3-dcb0-4cf2-a203-9654808af92e
# ╟─146b8d51-cc90-412c-84a7-dae2d0d1d09b
# ╠═ff92d7a8-53cc-46b2-9e06-205d2cbaccec
# ╠═e3ad99e1-7350-474d-8561-50fb1a3daecc
# ╠═05be1e42-8fc7-4abb-8b0e-620f1edb0251
# ╟─46344934-cad7-42c2-8f2c-9d367c6634fc
# ╠═8846351d-5108-4f0b-8c85-c6c68a6b1a53
# ╠═51ed93f5-4cf2-4974-b966-55faaeca485d
# ╠═c80a7658-2562-4744-bff6-467815d99bc1
# ╟─f13e3e21-e97d-4705-840b-df26e32616c6
# ╠═7f0cd2ba-d74b-48c1-8ef4-b2e37ecac80b
# ╠═830448cd-23bf-469b-a5f0-8104d9ec4961
# ╟─483c4a28-8483-42e8-b894-9e91542cea64
# ╠═48cd757c-b2c3-45b4-b314-1a62af57e895
# ╠═ef40a8cd-55e0-4b57-9cba-11fa50284838
# ╠═b5332544-2fa8-42d8-80b1-021fd36cafaf
# ╠═c7d68f3e-2e09-41cc-9f98-f50a7a567aad
# ╟─3e968151-bce2-4af9-bf1b-cdfe0112a907
# ╠═186c6ed1-c938-4f5c-b9ee-a51ad283c3c5
# ╠═609cf04b-7874-466d-806f-12ebd80e1d7c
# ╠═b3a5183f-4c8f-48df-b094-cc688a070af2
# ╠═cdfca0b3-8b3c-4cb1-b2c5-cece147edbda
# ╟─4a6876a3-857c-4d7c-8ffa-2d35bac59cd9
# ╠═65cf4392-847d-4384-b36f-6925f281223d
# ╠═304a0263-1a04-4d67-9e0f-33a753aa1b55
# ╠═ea069802-e118-4dea-ba8f-b6c3d877a876
# ╠═ac6bb46b-ea0a-43a9-bba4-57d930764d3a
# ╠═0f14108e-64f0-4b21-b4f9-9929978af453
# ╟─e90faa5d-af8b-4a4c-a5af-84eaf000839d
# ╠═56a3a697-4114-4b90-a94b-e66805a66fdd
# ╠═c202e08a-a347-4821-94d4-32636ad3bd06
# ╠═2486d867-388d-4b50-ae34-c4a3f4f6e726
# ╠═ee5d4f11-72c7-4cd1-bb53-9945e26ab5fb
# ╠═aec8a241-2901-4762-bb88-a7408e2e11d8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
