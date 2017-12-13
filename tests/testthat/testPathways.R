context("Pathway functions")

humanSpeciesStr = "hsa"
humanSample = "hsa03320"

test_that("load.pathways always require an species", {
    expect_error(load.pathways(), "is missing")
})

test_that("load.pathways always returns a list", {
    pathways <- load.pathways(species = "hsa", pathways.list=humanSample)
    expect_is(pathways, "list")
    expect_equal(length(get.pathways.list(pathways)), 1)
    expect_equal(get.pathways.list(pathways), humanSample)
    expect_equal(pathways$species, humanSpeciesStr)
})
