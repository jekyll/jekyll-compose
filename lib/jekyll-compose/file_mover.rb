module Jekyll
  module Compose
    class FileMover
      attr_reader :movement, :root
      def initialize(movement, root = nil)
        @movement = movement
        @root = root
      end

      def resource_type
        "file"
      end

      def move
        validate_source
        ensure_directory_exists
        move_file
      end

      def validate_source
        raise ArgumentError, "There was no #{resource_type} found at '#{from}'." unless File.exist? from
      end

      def ensure_directory_exists
        dir = File.dirname to
        Dir.mkdir(dir) unless Dir.exist?(dir)
      end

      def move_file
        FileUtils.mv(from, to)
        puts "#{resource_type.capitalize} #{from} was moved to #{to}"
      end

      private
      def from
        movement.from
      end

      def to
        file_path(movement.to)
      end

      def file_path(path)
        return path if root.nil? || root.empty?
        return File.join(root, path)
      end
    end
  end
end
