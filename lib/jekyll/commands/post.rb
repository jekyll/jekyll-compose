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

      class PostArgParser
        attr_reader :args, :options
        def initialize(args=[], options={})
          @args = args
          @options = options
        end

        def validate!
          raise ArgumentError.new('You must specify a name.') if args.empty?
        end

        def type
          type = options["type"] || Jekyll::Compose::DEFAULT_TYPE
        end

        def layout
          layout = options["layout"] || Jekyll::Compose::DEFAULT_LAYOUT
        end

        def date
          date = options["date"].nil? ? Time.now : DateTime.parse(options["date"])
        end

        def title
          args[0]
        end

        def name
          title.gsub(' ', '-').downcase
        end

        def force?
          options["force"]
        end
      end

      class PostCreator
        attr_reader :path, :content, :force
        def initialize(path, content, force=false)
          @path = path
          @content = content
          @force = force
        end

        def create!
          validate_should_write!
          ensure_directory_exists
          write_file
        end

        private

        def validate_should_write!
          raise ArgumentError.new("A post already exists at ./#{path}") if File.exist?(path) and !force
        end

        def ensure_directory_exists
          Dir.mkdir("_posts") unless Dir.exist?("_posts")
        end

        def write_file
          File.open(path, "w") do |f|
            f.puts(content)
          end

          puts "New post created at ./#{path}.\n"
        end
      end

      def self.process(args = [], options = {})
        params = PostArgParser.new args, options
        params.validate!

        post_path = file_name(params.name, params.type, params.date)

        content = front_matter(params.layout, params.title)

        PostCreator.new(post_path, content, params.force?).create!

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
