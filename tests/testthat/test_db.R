context("DB operations")
library(popcycle)

source("helper.R")

test_that("Load / Delete SFL", {
  x <- setUp()

  # Load SFL data
  save.sfl(x$db, sfl.file=x$sfl.file, cruise=x$cruise, inst=x$serial)
  sfl <- get.sfl.table(x$db)
  expect_true(nrow(sfl) == 5)
  reset.sfl.table(x$db)
  sfl <- get.sfl.table(x$db)
  expect_true(nrow(sfl) == 0)

  tearDown(x)
})

test_that("Save and retrieve filter params", {
  x <- setUp()

  inflection <- data.frame(fsc=c(33759), d1=c(19543), d2=c(19440))
  filter.params1 <- create.filter.params("740", inflection$fsc, inflection$d1, inflection$d2)
  filter.params2 <- create.filter.params("740", inflection$fsc+1, inflection$d1+1, inflection$d2+1)

  id1 <- save.filter.params(x$db, filter.params1)
  id2 <- save.filter.params(x$db, filter.params2)

  latest <- get.filter.params.latest(x$db)
  oldest <- get.filter.params.by.id(x$db, id1)

  # Skip id and date when comparing
  expect_equal(oldest[, 3:ncol(oldest)], filter.params1)
  expect_equal(latest[, 3:ncol(latest)], filter.params2)

  tearDown(x)
})

test_that("Retrieve OPP stats by file", {
  x <- setUp()

  opp <- get.opp.stats.by.file(x$db.full, "2014_185/2014-07-04T00-00-02+00-00")
  expect_equal(nrow(opp), 3)
  expect_equal(unique(opp$file), "2014_185/2014-07-04T00-00-02+00-00")

  tearDown(x)
})

test_that("Retrieve VCT stats by file", {
  x <- setUp()

  vct <- get.vct.stats.by.file(x$db.full, "2014_185/2014-07-04T00-03-02+00-00")
  expect_equal(nrow(vct), 12)
  expect_equal(unique(vct$file), "2014_185/2014-07-04T00-03-02+00-00")

  tearDown(x)
})

test_that("Retrieve OPP stats by date", {
  x <- setUp()

  opp <- get.opp.stats.by.date(x$db.full, "2014-07-04 00:00", "2014-07-04 00:04")
  opp <- opp[order(opp$file), ]
  expect_equal(
    opp$file,
    c(rep("2014_185/2014-07-04T00-00-02+00-00", 3), rep("2014_185/2014-07-04T00-03-02+00-00", 3))
  )

  opp <- get.opp.stats.by.date(x$db.full, "2014-07-04 00:03", "2014-07-04 00:10")
  expect_equal(opp$file, rep("2014_185/2014-07-04T00-03-02+00-00", 3))

  tearDown(x)
})

test_that("Retrieve VCT stats by date", {
  x <- setUp()

  vct <- get.vct.stats.by.date(x$db.full, "2014-07-04 00:00", "2014-07-04 00:04")
  expect_equal(
    vct$file,
    c(rep("2014_185/2014-07-04T00-00-02+00-00", 12), rep("2014_185/2014-07-04T00-03-02+00-00", 12))
  )

  tearDown(x)
})

test_that("Retrieve OPP by file", {
  x <- setUp()

  # Without VCT, transformed
  opp <- get.opp.by.file(x$opp.input.dir, get.opp.files(x$db.full)[1:2], 50)
  expect_equal(nrow(opp), 289)
  expect_true(!any(max(opp[, length(popcycle:::EVT.HEADER)]) > 10^3.5))

  # Without VCT, not transformed
  opp <- get.opp.by.file(x$opp.input.dir, get.opp.files(x$db.full)[1:2], 50, transform=F)
  expect_equal(nrow(opp), 289)
  expect_true(any(max(opp[, seq(3, length(popcycle:::EVT.HEADER))]) > 10^3.5))

  # With VCT
  opp <- get.opp.by.file(x$opp.input.dir, get.opp.files(x$db.full)[1:2], 50, vct.dir=x$vct.input.dir)
  expect_true("pop" %in% names(opp))

  tearDown(x)
})

test_that("Retrieve OPP by date", {
  x <- setUp()

  # Without VCT, transformed
  opp <- get.opp.by.date(x$db.full, x$opp.input.dir, 50, "2014-07-04 00:00", "2014-07-04 00:04")
  expect_equal(nrow(opp), 289)
  expect_true(!any(max(opp[, length(popcycle:::EVT.HEADER)]) > 10^3.5))

  # Without VCT, not transformed
  opp <- get.opp.by.date(x$db.full, x$opp.input.dir, 50, "2014-07-04 00:00", "2014-07-04 00:04",
                         transform=F)
  expect_equal(nrow(opp), 289)
  expect_true(any(max(opp[, seq(3, length(popcycle:::EVT.HEADER))]) > 10^3.5))

  # With VCT
  opp <- get.opp.by.date(x$db.full, x$opp.input.dir, 50, "2014-07-04 00:00", "2014-07-04 00:04",
                         vct.dir=x$vct.input.dir)
  expect_true("pop" %in% names(opp))

  tearDown(x)
})

test_that("Retrieve EVT file names by date", {
  x <- setUp()

  evt.files <- get.evt.files.by.date(x$db.full, x$evt.input.dir, "2014-07-04 00:03", "2014-07-04 00:10")
  answer <- c(
    "2014_185/2014-07-04T00-03-02+00-00",
    "2014_185/2014-07-04T00-06-02+00-00",
    "2014_185/2014-07-04T00-09-02+00-00"
  )
  expect_equal(evt.files, answer)

  tearDown(x)
})
