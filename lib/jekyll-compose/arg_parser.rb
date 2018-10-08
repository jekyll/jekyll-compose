# frozen_string_literal: true

module Jekyll
  module Compose
    class ArgParser
      attr_reader :args, :options, :config
      def initialize(args, options)
        @args = args
        @options = options
        @config = Jekyll.configuration(options)
      end

      def validate!
        raise ArgumentError, "You must specify a name." if args.empty?
      end

      def type
        options["extension"] || Jekyll::Compose::DEFAULT_TYPE
      end

      def layout
        options["layout"] || Jekyll::Compose::DEFAULT_LAYOUT
      end

      def title
        args.join " "
      end

      def force?
        !!options["force"]
      end

      def source
        File.join(config["source"], config["collections_dir"])
          .gsub(%r!^#{Regexp.quote(Dir.pwd)}/*!, "")
      end
    end
  end
end
