module TestSort
    using Base.Test, DataFrames

    dv1 = [9, 1, 8, missing, 3, 3, 7, missing]
    dv2 = [9, 1, 8, missing, 3, 3, 7, missing]
    dv3 = Vector{Union{Int, Missing}}(1:8)
    cv1 = CategoricalArray(dv1, ordered=true)

    d = DataFrame(dv1 = dv1, dv2 = dv2, dv3 = dv3, cv1 = cv1)

    @test sortperm(d) == sortperm(dv1)
    @test sortperm(d[[:dv3, :dv1]]) == sortperm(dv3)
    @test sort(d, cols=:dv1)[:dv3] == sortperm(dv1)
    @test sort(d, cols=:dv2)[:dv3] == sortperm(dv1)
    @test sort(d, cols=:cv1)[:dv3] == sortperm(dv1)
    @test sort(d, cols=[:dv1, :cv1])[:dv3] == sortperm(dv1)
    @test sort(d, cols=[:dv1, :dv3])[:dv3] == sortperm(dv1)

    df = DataFrame(rank=rand(1:12, 1000),
                   chrom=rand(1:24, 1000),
                   pos=rand(1:100000, 1000))

    @test issorted(sort(df))
    @test issorted(sort(df, rev=true), rev=true)
    @test issorted(sort(df, cols=[:chrom,:pos])[[:chrom,:pos]])

    ds = sort(df, cols=(order(:rank, rev=true),:chrom,:pos))
    @test issorted(ds, cols=(order(:rank, rev=true),:chrom,:pos))
    @test issorted(ds, rev=(true, false, false))

    ds2 = sort(df, cols=(:rank, :chrom, :pos), rev=(true, false, false))
    @test issorted(ds2, cols=(order(:rank, rev=true), :chrom, :pos))
    @test issorted(ds2, rev=(true, false, false))

    @test ds2 == ds

    sort!(df, cols=(:rank, :chrom, :pos), rev=(true, false, false))
    @test issorted(df, cols=(order(:rank, rev=true), :chrom, :pos))
    @test issorted(df, rev=(true, false, false))

    @test df == ds

    # Check that columns that shares the same underlying array are only permuted once PR#1072
    df = DataFrame(a=[2,1])
    df[:b] = df[:a]
    sort!(df, cols=:a)
    @test df == DataFrame(a=[1,2],b=[1,2])
end
