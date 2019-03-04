'use strict';

var gulp = require('gulp'),
    sass = require('gulp-sass');

gulp.task('sass', function () {
  gulp.src(['./hammer/scss/*.scss','!./hammer/scss/_*.scss'])
    .pipe(sass({outputStyle: 'compressed'}).on('error', sass.logError))
    .pipe(gulp.dest('./hammer/css/'));
});

gulp.task('default',['sass'], function(){
  gulp.watch(['./hammer/scss/**/*.scss'], ['sass']);
});
