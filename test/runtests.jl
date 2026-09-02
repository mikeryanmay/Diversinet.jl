using Diversinet
using Test

const TEST_TREE = "((A:0.5,B:0.5):0.25,C:0.75):0.25;"

@testset "package and native interface load" begin
    @test isdefined(Diversinet, :DiversinetInterface)
end

@testset "network parsing" begin
    model = Diversinet.DiversinetModel(TEST_TREE; λ=0.5, μ=0.1, ρ=0.5, kmax=16)
    @test model.newick == TEST_TREE
    finalize(model)
end

@testset "likelihood" begin
    loglik = Diversinet.computeLogLikelihood(TEST_TREE; λ=0.5, μ=0.1, ρ=0.5, kmax=16)
    @test isfinite(loglik)
end

@testset "simulation" begin
    networks = Diversinet.simulate(1.0, 1; λ=1.0, condition=Diversinet.Tree, root=true)
    @test length(networks) == 1
    @test only(networks) isa String
    @test !isempty(only(networks))
end

@testset "argument errors" begin
    @test_throws DomainError Diversinet.simulate(-1.0, 1)
end
