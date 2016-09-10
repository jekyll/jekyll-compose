module Jekyll
  module Commands
    class Publish < Command
      def self.init_with_program(prog)
        prog.command(:publish) do |c|
          c.syntax 'publish DRAFT_PATH'
          c.description 'Moves a draft into the _posts directory and sets the date'

          c.option 'date', '-d DATE', '--date DATE', 'Specify the post date'
          c.option 'config', '--config CONFIG_FILE[,CONFIG_FILE2,...]', Array, 'Custom configuration file'
          c.option 'source', '-s', '--source SOURCE', 'Custom source directory'

          c.action do |args, options|
            Jekyll::Commands::Publish.process(args, options)
          end
        end
      end

      def self.process(args = [], options = {})
        params = PublishArgParser.new args, options
        params.validate!

        movement = DraftMovementInfo.new params

        mover = DraftMover.new movement, params.source
        mover.move
      end

    end

    class PublishArgParser < Compose::MovementArgParser
      def resource_type
        "draft"
      end

      def date
        options["date"].nil? ? Date.today : Date.parse(options["date"])
      end

      def name
        File.basename path
      end
    end

    class DraftMovementInfo
      attr_reader :params
      def initialize(params)
        @params = params
      end

      def from
        params.path
      end

      def to
        date_stamp = params.date.strftime '%Y-%m-%d'
        "_posts/#{date_stamp}-#{params.name}"
      end
    end

    class DraftMover < Compose::FileMover
      def resource_type
        'draft'
      end
    end
  end
end
