using Compat

tests =["testdata",
		"populategraphtest",
        "compositequerytest"]

println("Running tests:")

for t in tests
    testfilepath = joinpath(Pkg.dir("PropertyGraph"),"test","$(t).jl")
    println("running $(testfilepath) ...")
    include(testfilepath)
end
