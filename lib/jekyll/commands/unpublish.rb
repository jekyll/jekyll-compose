# frozen_string_literal: true

module Jekyll
  module Commands
    class Unpublish < Command
      def self.init_with_program(prog)
        prog.command(:unpublish) do |c|
          c.syntax "unpublish POST_PATH"
          c.description "Moves a post back into the _drafts directory"

          c.option "config", "--config CONFIG_FILE[,CONFIG_FILE2,...]", Array, "Custom configuration file"
          c.option "force", "-f", "--force", "Overwrite a draft if it already exists"
          c.option "source", "-s", "--source SOURCE", "Custom source directory"

          c.action do |args, options|
            process(args, options)
          end
        end
      end

      def self.process(args = [], options = {})
        config = configuration_from_options(options)
        params = UnpublishArgParser.new args, options, config
        params.validate!

        movement = PostMovementInfo.new params

        mover = PostMover.new movement, params.force?, params.source
        mover.move
      end
    end

    class UnpublishArgParser < Compose::MovementArgParser
      def resource_type
        "post"
      end

      def name
        File.basename(path).sub %r!\d{4}-\d{2}-\d{2}-!, ""
      end
    end

    class PostMovementInfo
      attr_reader :params
      def initialize(params)
        @params = params
      end

      def from
        params.path
      end

      def to
        "_drafts/#{params.name}"
      end
    end

    class PostMover < Compose::FileMover
      def resource_type_from
        "post"
      end

      def resource_type_to
        "draft"
      end
    end
  end
end
