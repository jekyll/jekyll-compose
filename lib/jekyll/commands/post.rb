module Jekyll
  module Commands
    class Post < Command
      def self.init_with_program(prog)
        prog.command(:post) do |c|
          c.syntax syntax
          c.description description

          options.each {|opt| c.option *opt }

          c.action { |args, options| process args, options }
        end
      end

      def self.syntax
        'post NAME'
      end

      def self.description
        'Creates a new post with the given NAME'
      end

      def self.options
        [
          ['type', '-t TYPE', '--type TYPE', 'Specify the content type (file extension)'],
          ['layout', '-l LAYOUT', '--layout LAYOUT', "Specify the post layout"],
          ['force', '-f', '--force', 'Overwrite a post if it already exists'],
          ['date', '-d DATE', '--date DATE', 'Specify the post date']
        ]
      end

      def self.process(args = [], options = {})
        params = PostArgParser.new args, options
        params.validate!

        post = PostFileInfo.new params

        Compose::FileCreator.new(post, params.force?).create!
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
          dashing_title = params.title.gsub(' ', '-').downcase
          "_posts/#{_date_stamp}-#{dashing_title}.#{params.type}"
        end

        def content
          <<-CONTENT.gsub /^\s+/, ''
            ---
            layout: #{params.layout}
            title: #{params.title}
            ---
          CONTENT
        end

        def _date_stamp
          @params.date.strftime '%Y-%m-%d'
        end
      end
    end
  end
end
