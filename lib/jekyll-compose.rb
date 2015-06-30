require "jekyll-compose/version"
require "jekyll-compose/arg_parser"
require "jekyll-compose/movement_arg_parser"
require "jekyll-compose/file_creator"
require "jekyll-compose/file_mover"
require "jekyll-compose/file_info"

module Jekyll
  module Compose
    DEFAULT_TYPE = "md"
    DEFAULT_LAYOUT = "post"
    DEFAULT_LAYOUT_PAGE = "page"
  end
end

%w{draft post publish unpublish page}.each do |file|
  require File.expand_path("jekyll/commands/#{file}.rb", File.dirname(__FILE__))
end
