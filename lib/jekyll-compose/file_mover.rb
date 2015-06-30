module Jekyll
  module Compose
    class FileMover
      attr_reader :movement
      def initialize(movement)
        @movement = movement
      end

      def resource_type
        'file'
      end

      def move
        validate_source
        ensure_directory_exists
        move_file
      end

      def validate_source
        raise ArgumentError.new("There was no #{resource_type} found at '#{movement.from}'.") unless File.exist? movement.from
      end

      def ensure_directory_exists
        dir = File.dirname movement.to
        Dir.mkdir(dir) unless Dir.exist?(dir)
      end

      def move_file
        FileUtils.mv(movement.from, movement.to)
        puts "#{resource_type.capitalize} #{movement.from} was moved to #{movement.to}"
      end
    end
  end
end
