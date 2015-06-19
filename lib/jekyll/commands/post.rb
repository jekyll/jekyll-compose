module Jekyll
  module Commands
    class Post < Command
      def self.init_with_program(prog)
        prog.command(:post) do |c|
          c.syntax 'post NAME'
          c.description 'Creates a new post with the given NAME'

          Compose::FileCreationOptions.new('post').create_options c

          c.option 'date', '-d DATE', '--date DATE', 'Specify the post date'

          c.action do |args, options|
            Jekyll::Commands::Post.process(args, options)
          end
        end
      end

      def self.process(args = [], options = {})
        raise ArgumentError.new('You must specify a name.') if args.empty?

        type = options["type"] || Jekyll::Compose::DEFAULT_TYPE
        layout = options["layout"] || Jekyll::Compose::DEFAULT_LAYOUT

        date = options["date"].nil? ? Time.now : DateTime.parse(options["date"])

        title = args.shift
        name = title.gsub(' ', '-').downcase

        post_path = file_name(name, type, date)

        raise ArgumentError.new("A post already exists at ./#{post_path}") if File.exist?(post_path) and !options["force"]

        Dir.mkdir("_posts") unless Dir.exist?("_posts")
        File.open(post_path, "w") do |f|
          f.puts(front_matter(layout, title))
        end

        puts "New post created at ./#{post_path}.\n"
      end
      # Internal: Gets the filename of the draft to be created
      #
      # Returns the filename of the draft, as a String
      def self.file_name(name, ext, date)
        "_posts/#{date.strftime('%Y-%m-%d')}-#{name}.#{ext}"
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
