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

      class PostArgParser < Compose::ArgParser
        def date
          date = options["date"].nil? ? Time.now : DateTime.parse(options["date"])
        end
      end

      class PostFileInfo
        attr_reader :params
        def initialize(params)
          @params = params
        end

        def resource_type
          'post'
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

        Compose::FileCreator.new(post, params.force?).create!

      end
    end
  end
end
