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

      def self.process(args = [], options = {})
        params = PublishArgParser.new args, options
        params.validate!

        movement = DraftMovementInfo.new params

        mover = DraftMover.new movement
        mover.move
      end

    end

    class PublishArgParser
      attr_reader :args, :options
      def initialize(args, options)
        @args = args
        @options = options
      end

      def validate!
        raise ArgumentError.new('You must specify a draft path.') if args.empty?
      end

      def date
        options["date"].nil? ? Date.today : Date.parse(options["date"])
      end

      def draft_path
        args.join ' '
      end

      def draft_name
        File.basename draft_path
      end
    end

    class DraftMovementInfo
      attr_reader :params
      def initialize(params)
        @params = params
      end

      def from
        params.draft_path
      end

      def to
        "_posts/#{_date_stamp}-#{params.draft_name}"
      end

      def _date_stamp
        params.date.strftime '%Y-%m-%d'
      end
    end

    class DraftMover
      attr_reader :movement
      def initialize(movement)
        @movement = movement
      end

      def move
        validate_source
        ensure_directory_exists
        move_file
      end

      def validate_source
        raise ArgumentError.new("There was no draft found at '#{movement.from}'.") unless File.exist? movement.from
      end

      def ensure_directory_exists
        Dir.mkdir("_posts") unless Dir.exist?("_posts")
      end

      def move_file
        FileUtils.mv(movement.from, movement.to)
        puts "Draft #{movement.from} was published to #{movement.to}"
      end
    end
  end
end
