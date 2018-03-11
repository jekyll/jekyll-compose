# frozen_string_literal: true

require "jekyll-compose/version"
require "jekyll-compose/arg_parser"
require "jekyll-compose/movement_arg_parser"
require "jekyll-compose/file_creator"
require "jekyll-compose/file_mover"
require "jekyll-compose/file_info"
require "jekyll-compose/file_editor"

module Jekyll
  module Compose
    DEFAULT_TYPE = "md".freeze
    DEFAULT_LAYOUT = "post".freeze
    DEFAULT_LAYOUT_PAGE = "page".freeze
  end
end

%w(draft post publish unpublish page).each do |file|
  require File.expand_path("jekyll/commands/#{file}.rb", __dir__)
end
