module Jekyll
  module Compose
    class MovementArgParser
      attr_reader :args, :options, :config
      def initialize(args, options)
        @args = args
        @options = options
        @config = Jekyll.configuration(options)
      end

      def validate!
        raise ArgumentError, "You must specify a #{resource_type} path." if args.empty?
      end

      def path
        args.join " "
      end

      def source
        source = config["source"].gsub(%r!^#{Regexp.quote(Dir.pwd)}!, "")
      end
    end
  end
end
