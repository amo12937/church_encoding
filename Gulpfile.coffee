"use strict"

gulp = require "gulp"

do (del = require "del") ->
  gulp.task "clean", (done) ->
    del ["dist/**/*"], done

do (browserify = require("gulp-browserify"), rename = require "gulp-rename") ->
  gulp.task "scripts", ->
    gulp.src "src/scripts/app.coffee", read: false
      .pipe browserify transform: ["coffeeify"], extensions: [".coffee"]
      .pipe rename "app.js"
      .pipe gulp.dest "dist/scripts"

do (haml = require "gulp-haml") ->
  gulp.task "haml", ->
    gulp.src "src/index.haml"
      .pipe haml()
      .pipe gulp.dest "dist/"

do (sass = require("gulp-sass"), autoprefixer = require "gulp-autoprefixer") ->
  gulp.task "styles", ->
    gulp.src "src/styles/app.scss"
      .pipe sass()
      .pipe autoprefixer()
      .pipe gulp.dest "dist/styles"

do ->
  gulp.task "readme", ->
    gulp.src "src/README.md"
      .pipe gulp.dest "dist"

do (mocha = require "gulp-mocha") ->
  require "coffee-script/register"
  gulp.task "nyan", ->
    gulp.src "spec/scripts/**/*.coffee", read: false
      .pipe mocha reporter: "nyan"

gulp.task "build", gulp.series "clean", gulp.parallel "scripts", "haml", "styles", "readme"
