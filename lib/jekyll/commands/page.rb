module Jekyll
  module Commands
    class Page < Command
      def self.init_with_program(prog)
        prog.command(:page) do |c|
          c.syntax syntax
          c.description description

          options.each {|opt| c.option *opt }

          c.action { |args, options| process args, options }
        end
      end

      def self.syntax
        'page NAME'
      end

      def self.description
        'Creates a new page with the given NAME'
      end

      def self.options
        [
          ['type', '-t TYPE', '--type TYPE', 'Specify the content type (file extension)'],
          ['layout', '-l LAYOUT', '--layout LAYOUT', "Specify the post layout"],
          ['force', '-f', '--force', 'Overwrite a post if it already exists']
        ]
      end

      def self.process(args = [], options = {})
        params = PageArgParser.new args, options
        params.validate!

        page = PageFileInfo.new params

        Compose::FileCreator.new(page, params.force?).create!
      end

      class PageArgParser < Compose::ArgParser
        def layout
          layout = options["layout"] || Jekyll::Compose::DEFAULT_LAYOUT_PAGE
        end
      end

      class PageFileInfo
        attr_reader :params
        def initialize(params)
          @params = params
        end

        def resource_type
          'page'
        end

        def path
          name = params.title.gsub(' ', '-').downcase
          "#{name}.#{params.type}"
        end

        def content
          <<-CONTENT.gsub /^\s+/, ''
            ---
            layout: #{params.layout}
            title: #{params.title}
            ---
          CONTENT
        end

      end


      # Returns the filename
      def self.file_name(name, ext)
        "./#{name}.#{ext}"
      end

      def self.front_matter(layout, title)
        "---
layout: #{layout}
title: #{title}
---"
      end
    end
  end
end
