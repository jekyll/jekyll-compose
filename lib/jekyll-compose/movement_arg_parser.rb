module Jekyll
  module Compose
    class MovementArgParser
      attr_reader :args, :options
      def initialize(args, options)
        @args = args
        @options = options
      end

      def validate!
        raise ArgumentError.new("You must specify a #{resource_type} path.") if args.empty?
      end

      def path
        args.join ' '
      end
    end
  end
end
