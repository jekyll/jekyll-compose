module Jekyll
  module Commands
    class Post < Command
      def self.init_with_program(prog)
        prog.command(:post) do |c|
          c.syntax 'post NAME'
          c.description 'Creates a new post with the given NAME'

          options.each {|opt| c.option *opt }

          c.action { |args, options| process args, options }
        end
      end

      def self.options
        [
          ['extension', '-x EXTENSION', '--extension EXTENSION', 'Specify the file extension'],
          ['layout', '-l LAYOUT', '--layout LAYOUT', "Specify the post layout"],
          ['force', '-f', '--force', 'Overwrite a post if it already exists'],
          ['date', '-d DATE', '--date DATE', 'Specify the post date'],
          ['config', '--config CONFIG_FILE[,CONFIG_FILE2,...]', Array, 'Custom configuration file'],
          ['source', '-s', '--source SOURCE', 'Custom source directory'],
        ]
      end

      def self.process(args = [], options = {})
        params = PostArgParser.new args, options
        params.validate!

        post = PostFileInfo.new params

        Compose::FileCreator.new(post, params.force?, params.source).create!
      end


      class PostArgParser < Compose::ArgParser
        def date
          options["date"].nil? ? Time.now : DateTime.parse(options["date"])
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
