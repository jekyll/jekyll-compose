module Jekyll
  module Commands
    class Publish < Command
      def self.init_with_program(prog)
        prog.command(:publish) do |c|
          c.syntax 'publish DRAFT_PATH'
          c.description 'Moves a draft into the _posts directory and sets the date'

          c.option 'date', '-d DATE', '--date DATE', 'Specify the post date'

          c.action do |args, options|
            Jekyll::Commands::Publish.process(args, options)
          end
        end
      end

      def self.process(args, options = {})
        raise ArgumentError.new('You must specify a draft path.') if args.empty?

        date = options["date"].nil? ? Date.today : Date.parse(options["date"])
        draft_path = args.shift

        raise ArgumentError.new("There was no draft found at '#{draft_path}'.") unless File.exist? draft_path

        post_path = post_name(date, draft_name(draft_path))
        FileUtils.mv(draft_path, post_path)

        puts "Draft #{draft_path} was published to ./#{post_path}"
      end

      # Internal: Gets the filename of the post to be created
      #
      # Returns the filename of the post, as a String
      def self.post_name(date, name)
        "_posts/#{date.strftime('%Y-%m-%d')}-#{name}"
      end

      def self.draft_name(path)
        File.basename(path)
      end

    end
  end
end
