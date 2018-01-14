# frozen_string_literal: true

module Jekyll
  module Compose
    class MovementArgParser < ArgParser

      def validate!
        raise ArgumentError, "You must specify a #{resource_type} path." if args.empty?
      end

      def path
        args.join " "
      end
    end
  end
end
