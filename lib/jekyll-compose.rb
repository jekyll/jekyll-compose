require "jekyll-compose/version"

module Jekyll
  module Compose
    DEFAULT_TYPE = "md"
    DEFAULT_LAYOUT = "post"
    DEFAULT_LAYOUT_PAGE = "page"
  end
end

%w{draft post publish page}.each do |file|
  require File.expand_path("jekyll/commands/#{file}.rb", File.dirname(__FILE__))
end
