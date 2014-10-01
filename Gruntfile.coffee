module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    src:
      sass: 'src/sass'
      coffee: 'src/coffee'
    dev:
      root: 'dev'
      css: 'dev/css'
      js: 'dev/js'
    dist:
     root: 'dist'
     css: 'dist/css'
     js: 'dist/js'
    config: 'config'

    copy:
      dist:
        expand: true
        cwd: '<%= dev.root %>'
        src: '**/*'
        dest: '<%= dist.root %>'

    compress:
      options: archive: '<%= pkg.name %>.zip'
      dist:
        files: [
          {
            expand: true
            cwd: '<%= dist.root %>'
            src: '**/*'
          }
        ]

    imagemin:
      watch:
        expand: true
        src: '<%= dist.root %>/**/*.{png,jpg,jpeg,gif}'


    htmlmin:
      options:
        removeComments: true
        collapseWhitespace: true
        collapseBooleanAttributes: true
        minifyJS: true
        minifyCSS: true
      build: { expand: true, src: '<%= dist.root %>**/*.html' }


    # sass:
    #   options:
    #     style: 'expanded'
    #     loadPath: '/.web/sass'
    #   watch:
    #     expand: true
    #     src: '<%= src.sass %>/**/*.{sass,scss}'
    #     dest: '<%= dev.css %>'
    #     ext: '.css'
    #     flatten: true

    # cmq:
    #   options: log: true
    #   build:
    #     src: '<%= dist.css %>/*.css'
    #     dest: '<%= dist.css %>'

    # csscomb:
    #   build:
    #     expand: true
    #     src: '<%= cmq.build.src %>'

    # csso:
    #   build:
    #     expand: true
    #     src: '<%= cmq.build.src %>'

    browserify:
      options:
        transform: ['coffeeify', 'debowerify']
        browserifyOptions:
          extensions: ['.coffee']
          debug: true
      dev:
        files: [
          '<%= dev.js %>/background.js': '<%= src.coffee %>/background.coffee'
          '<%= dev.js %>/a.js': '<%= src.coffee %>/a.coffee'
        ]
      test:
        files: [
          'test/spec/testSpec.js': 'test/src/spec/testSpec.coffee'
          'test/helper/chromeHelper.js': 'test/src/helper/chromeHelper.coffee'
        ]

    coffee:
      no:
        expand: true
        src: ['<%= src.coffee %>/*.coffee', '!<%= src.coffee %>/*.ng.coffee']
        dest: '<%= dev.js %>'
        ext: '.js'
        flatten: true
      test:
        expand: true
        cwd: 'test/src'
        src: '**/*.coffee'
        dest: 'test/'
        ext: '.js'
      ng:
        expand: true
        src: '<%= src.coffee %>/*.ng.coffee'
        dest: '<%= dev.js %>'
        ext: '.ng.js'
        flatten: true

    ngmin: build: { expand: true, src: '<%= dist.js %>/*.ng.js'}

    uglify:
      options: mangle: false
      build:
        expand: true
        cwd: '<%= dist.js %>'
        src: ['**/*.js']
        dest: '<%= dist.js %>'

    jasmine:
      test:
        src: '<%= dev.js %>/*.js'
        options:
          helpers: 'test/**/*Helper.js'
          vendor: ['dev/js/lib/*.js', 'test/lib/*.js']
          specs: 'test/spec/*Spec.js'
          keepRunner: true


    watch:
      sass: {files: '<%= sass.watch.src %>', tasks: 'sass'}
      # coffee: {files: '<%= src.coffee %>/**/*.coffee', tasks: 'browserify:dev'}
      coffee: {files: '<%= src.coffee %>/**/*.coffee', tasks: 'coffee:no'}
      ng: {files: '<%= coffee.ng.src %>', tasks: 'coffee:ng'}
      test: {files: 'test/**/*.coffee', tasks: ['coffee:test', 'jasmine']}


  grunt.registerTask 'default', ['watch']
  grunt.registerTask 'dist', ['copy', 'htmlmin', 'ngmin', 'uglify', 'imagemin', 'compress']
  grunt.registerTask 'all', ['sass', 'coffee:no', 'coffee:ng' ,'copy', 'htmlmin', 'cmq', 'csscomb', 'csso', 'ngmin', 'uglify', 'imagemin', 'compress']


  # grunt.registerTask 'test', ['watch:test']
  # grunt.registerTask 'test', ['browserify:test', 'jasmine']
  # grunt.registerTask 'test', ['coffee', 'jasmine']

