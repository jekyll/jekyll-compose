module Jekyll
  module Compose
    class FileCreator
      attr_reader :file, :force
      def initialize(fileInfo, force = false)
        @file = fileInfo
        @force = force
      end

      def create!
        validate_should_write!
        ensure_directory_exists
        write_file
      end

      private

      def validate_should_write!
        raise ArgumentError.new("A #{file.resource_type} already exists at #{file.path}") if File.exist?(file.path) and !force
      end

      def ensure_directory_exists
        dir = File.dirname file.path
        Dir.mkdir(dir) unless Dir.exist?(dir)
      end

      def write_file
        File.open(file.path, "w") do |f|
          f.puts(file.content)
        end

        puts "New #{file.resource_type} created at #{file.path}."
      end
    end
  end
end
