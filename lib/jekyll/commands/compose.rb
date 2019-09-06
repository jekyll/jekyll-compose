# frozen_string_literal: true

module Jekyll
  module Commands
    class ComposeCommand < Command
      def self.init_with_program(prog)
        prog.command(:compose) do |c|
          c.syntax "compose NAME"
          c.description "Creates a new document with the given NAME"

          options.each { |opt| c.option *opt }

          c.action { |args, options| process args, options }
        end
      end

      def self.options
        [
          ["extension", "-x EXTENSION", "--extension EXTENSION", "Specify the file extension"],
          ["layout", "-l LAYOUT", "--layout LAYOUT", "Specify the document layout"],
          ["force", "-f", "--force", "Overwrite a document if it already exists"],
          ["date", "-d DATE", "--date DATE", "Specify the document date"],
          ["collection", "-c COLLECTION", "--collection COLLECTION", "Specify the document collection"],
          ["post", "--post", "Create a new post (default)"],
          ["draft", "--draft", "Create a new draft"],
          ["config", "--config CONFIG_FILE[,CONFIG_FILE2,...]", Array, "Custom configuration file"],
        ]
      end

      def self.process(args = [], options = {})
        config = configuration_from_options(options)
        params = ComposeCommandArgParser.new args, options, config
        params.validate!

        document = ComposeCommandFileInfo.new params

        file_creator = Compose::FileCreator.new(document, params.force?, params.source)
        file_creator.create!

        Compose::FileEditor.bootstrap(config)
        Compose::FileEditor.open_editor(file_creator.file_path)
      end

      class ComposeCommandArgParser < Compose::ArgParser
        def validate!
          if options.values_at("post", "draft", "collection").compact.length > 1
            raise ArgumentError, "You can only specify one of --post, --draft, or --collection COLLECTION."
          end

          super
        end

        def date
          options["date"] ? Date.parse(options["date"]) : Time.now
        end

        def collection
          if options["collection"]
            options["collection"]
          elsif options["post"]
            "posts"
          elsif options["draft"]
            "drafts"
          else
            "posts"
          end
        end
      end

      class ComposeCommandFileInfo < Compose::FileInfo
        def resource_type
          case @params.collection
          when "posts" then "post"
          when "drafts" then "draft"
          else
            "file"
          end
        end

        def path
          "#{_collection}/#{file_name}"
        end

        def file_name
          @params.collection == "posts" ? "#{_date_stamp}-#{super}" : super
        end

        def _date_stamp
          @params.date.strftime Jekyll::Compose::DEFAULT_DATESTAMP_FORMAT
        end

        def _time_stamp
          @params.date.strftime Jekyll::Compose::DEFAULT_TIMESTAMP_FORMAT
        end

        def _collection
          "_#{@params.collection}"
        end

        def content(custom_front_matter = {})
          default_front_matter =
            case @params.collection
            when "posts" then params.config.dig("jekyll_compose", "post_default_front_matter")
            when "drafts"then params.config.dig("jekyll_compose", "draft_default_front_matter")
            else
              params.config.dig("jekyll_compose", "default_front_matter", @params.collection)
            end

          custom_front_matter.merge!(default_front_matter) if default_front_matter.is_a?(Hash)

          super({ "date" => _time_stamp }.merge!(custom_front_matter))
        end
      end
    end
  end
end
