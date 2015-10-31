"use strict"

gulp = require "gulp"

do (del = require "del") ->
  gulp.task "clean", (done) ->
    del ["dist/**/*"], done

do (browserify = require "gulp-browserify", rename = require "gulp-rename") ->
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

gulp.task "build", gulp.series "clean", gulp.parallel "scripts", "haml"
