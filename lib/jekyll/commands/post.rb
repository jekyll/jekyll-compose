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

      class FileCreator
        attr_reader :file, :force
        def initialize(fileInfo, force=false)
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
          raise ArgumentError.new("A post already exists at ./#{file.path}") if File.exist?(file.path) and !force
        end

        def ensure_directory_exists
          Dir.mkdir("_posts") unless Dir.exist?("_posts")
        end

        def write_file
          File.open(file.path, "w") do |f|
            f.puts(file.content)
          end

          puts "New post created at ./#{file.path}.\n"
        end
      end

      class PostFileInfo
        attr_reader :params
        def initialize(params)
          @params = params
        end

        def path
          "_posts/#{date_stamp}-#{params.name}.#{params.type}"
        end

        def content
        "---
layout: #{params.layout}
title: #{params.title}
---"
        end

        private

        def date_stamp
          @params.date.strftime '%Y-%m-%d'
        end
      end

      def self.process(args = [], options = {})
        params = PostArgParser.new args, options
        params.validate!

        post = PostFileInfo.new params

        FileCreator.new(post, params.force?).create!

      end
    end
  end
end
