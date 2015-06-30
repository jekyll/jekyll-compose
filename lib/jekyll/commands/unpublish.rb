module Jekyll
  module Commands
    class Unpublish < Command
      def self.init_with_program(prog)
        prog.command(:unpublish) do |c|
          c.syntax 'unpublish POST_PATH'
          c.description 'Moves a post back into the _drafts directory'

          c.action do |args, options|
            process(args, options)
          end
        end
      end

      def self.process(args = [], options = {})
        params = UnpublishArgParser.new args, options
        params.validate!

        movement = PostMovementInfo.new params

        mover = PostMover.new movement
        mover.move
      end

    end

    class UnpublishArgParser
      attr_reader :args, :options
      def initialize(args, options)
        @args = args
        @options = options
      end

      def validate!
        raise ArgumentError.new('You must specify a post path.') if args.empty?
      end

      def post_path
        args.join ' '
      end

      def post_name
        File.basename(post_path).sub /\d{4}-\d{2}-\d{2}-/, ''
      end
    end

    class PostMovementInfo
      attr_reader :params
      def initialize(params)
        @params = params
      end

      def from
        params.post_path
      end

      def to
        "_drafts/#{params.post_name}"
      end
    end

    class PostMover
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
        raise ArgumentError.new("There was no post found at '#{movement.from}'.") unless File.exist? movement.from
      end

      def ensure_directory_exists
        Dir.mkdir("_drafts") unless Dir.exist?("_drafts")
      end

      def move_file
        FileUtils.mv(movement.from, movement.to)
        puts "Post #{movement.from} was moved to #{movement.to}"
      end
    end
  end
end
