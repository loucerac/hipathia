context("Core function.")

test_that("The recursive propagation tolerance should be > 0", {
    x <- NULL
    y <- NULL
    expect_error(hipathia(x, y, tol=-1), "> 0")
})
