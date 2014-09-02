require "jekyll-compose/version"

module Jekyll
  module Compose
  end
end

%w{draft post publish}.each do |file|
  require File.expand_path("jekyll/commands/#{file}.rb", File.dirname(__FILE__))
end
