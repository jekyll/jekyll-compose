require "jekyll/compose/version"

module Jekyll
  module Compose
    DEFAULT_TYPE = "md"
    DEFAULT_LAYOUT = "post"
  end
end

require "jekyll/commands/draft"
require "jekyll/commands/post"
require "jekyll/commands/publish"
