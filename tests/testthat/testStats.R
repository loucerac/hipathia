context("Stats functions")

kTolerance <- 1e-6
kNumFeatures <- 3
kNumsamples <- 3
kZeroVarianceData <- matrix(c(0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.5, -0.1, 1.1),
                            nrow=kNumsamples, ncol=kNumFeatures)
kZeroVarianceData <- t(kZeroVarianceData)

test_that("normalize.data on the Iris dataset", {
    data(iris)
    irisNormalized <- normalize.data(iris)
    expect_equal(max(irisNormalized), 1, tolerance=kTolerance)
    expect_equal(min(irisNormalized), 0, tolerance=kTolerance)
})

test_that("normalize.data on a dataset with zero variance", {
    dataNormalized <- normalize.data(kZeroVarianceData, by.gene=TRUE)
    expectedData <- matrix(c(0, 0, 0, 0, 0, 0, 0.5, 0.0, 1.0),
                           nrow=kNumsamples, ncol=kNumFeatures)
    expectedData = t(expectedData)

    expect_equal(dataNormalized, expectedData, tolerance=kTolerance)
})
