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

      class PostFileInfo < Compose::FileInfo
        def resource_type
          'post'
        end

        def path
          "_posts/#{file_name}"
        end

        def file_name
          "#{_date_stamp}-#{super}"
        end

        def _date_stamp
          @params.date.strftime '%Y-%m-%d'
        end
      end
    end
  end
end
