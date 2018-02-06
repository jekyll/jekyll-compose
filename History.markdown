## 0.7.0 / 2018-02-06

### Development Fixes

  * Add Rubocop autorrect offenses (#57)
  * Test against Ruby 2.5 (#56)

### Minor Enhancements

  * Check if a file should be overwritten when publishing or unpublishing a post (#59)

## 0.6.0 / 2017-11-14

### Development Fixes

  * Modernize Travis config (#53)
  * Define path with __dir__ (#51)
  * Inherit Jekyll&#39;s rubocop config for consistency (#52)
  * Execute FileInfo tests in source_dir, Fix tests (#46)

### Minor Enhancements

  * Add date to front matter when publish (#54)

## 0.5.0 / 2016-10-11

  * Allow Jekyll Source Directory (#42)
  * Ensure colons do not break titles (#39)
  * Require Jekyll 3 or higher (#40)

## 0.4.1 / 2015-12-30

  * Change Jekyll dependency to a runtime dependency to enforce v2.5.0 or greater

## 0.4.0 / 2015-12-30

  * Depend on jekyll at least of version 2.5.0 (#33)

## 0.3.0 / 2015-08-31

  * Add the `page` command (#15)
  * Add the `unpublish` command (#21)
  * Commands will create directories if necessary (#17, #23)
  * Display relative directories without ./ (#22)
  * Change `-t`, `--type` options to `-x`, `--extension` (#25)

## 0.2.1 / 2015-01-17

  * Create the `_drafts` dir if it's not already there (#11)
  * Update docs with usage examples (#10)

## 0.2.0 / 2015-01-10

  * Change the default file extension from `.markdown` to `.md` (#9)
  * The `publish` command should receive a path. (#7)
  * Rewrite the tests. (#3)

## 0.1.1 / 2014-12-29

  * Require the command files so it can be used via `:jekyll_plugins` (#5)

## 0.1.0 / 2014-12-29

  * Initial iteration of the `draft`, `post`, and `publish` commands.

## 0.0.0 / 2014-05-10

  * Birthday!
