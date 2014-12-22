using Compat

testfiles =["testdata",
		"testdatasocial",
		"populategraphtest",
        "compositequerytest",
		"socialgraphtest",
		"changetrackertest",
		"definetestgraphloader",
		"graphloadertest"
		]

println("Running tests:")

for t in testfiles
    testfilepath = joinpath(Pkg.dir("PropertyGraph"),"test","$(t).jl")
    println("running $(testfilepath) ...")
    include(testfilepath)
end

