module Jekyll
  module Commands
    class Page < Command
      def self.init_with_program(prog)
        prog.command(:page) do |c|
          c.syntax 'page NAME'
          c.description 'Creates a new page with the given NAME'

          c.option 'type', '-t TYPE', '--type TYPE', 'Specify the content type'
          c.option 'layout', '-t LAYOUT', '--layout LAYOUT', 'Specify the post layout'
          c.option 'force', '-f', '--force', 'Overwrite a post if it already exists'

          c.action do |args, options|
            Jekyll::Commands::Page.process(args, options)
          end
        end
      end

      def self.process(args = [], options = {})
        raise ArgumentError.new('You must specify a name.') if args.empty?

        type = options["type"] || Jekyll::Compose::DEFAULT_TYPE
        layout = options["layout"] || Jekyll::Compose::DEFAULT_LAYOUT_PAGE

        title = args.shift
        name = title.gsub(' ', '-').downcase

        path = file_name(name, type)

        raise ArgumentError.new("A page already exists at #{path}") if File.exist?(path) and !options["force"]

        File.open(path, "w") do |f|
          f.puts(front_matter(layout, title))
        end

        puts "New page created at #{path}.\n"
      end


      # Returns the filename
      def self.file_name(name, ext)
        "#{Dir.pwd}/#{name}.#{ext}"
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
