# frozen_string_literal: true

module Jekyll
  module Commands
    class Post < Command
      def self.init_with_program(prog)
        prog.command(:post) do |c|
          c.syntax "post NAME"
          c.description "Creates a new post with the given NAME"

          options.each { |opt| c.option *opt }

          c.action { |args, options| process args, options }
        end
      end

      def self.options
        [
          ["extension", "-x EXTENSION", "--extension EXTENSION", "Specify the file extension"],
          ["layout", "-l LAYOUT", "--layout LAYOUT", "Specify the post layout"],
          ["force", "-f", "--force", "Overwrite a post if it already exists"],
          ["date", "-d DATE", "--date DATE", "Specify the post date"],
          ["config", "--config CONFIG_FILE[,CONFIG_FILE2,...]", Array, "Custom configuration file"],
          ["source", "-s", "--source SOURCE", "Custom source directory"],
        ]
      end

      def self.process(args = [], options = {})
        params = PostArgParser.new args, options
        params.validate!

        post = PostFileInfo.new params

        file_creator = Compose::FileCreator.new(post, params.force?, params.source)
        file_creator.create!
        Compose::FileEditor.open_editor(file_creator.file_path)
      end

      class PostArgParser < Compose::ArgParser
        def date
          options["date"].nil? ? Time.now : Date.parse(options["date"])
        end
      end

      class PostFileInfo < Compose::FileInfo
        def resource_type
          "post"
        end

        def path
          "_posts/#{file_name}"
        end

        def file_name
          "#{_date_stamp}-#{super}"
        end

        def _date_stamp
          @params.date.strftime Jekyll::Compose::DEFAULT_DATESTAMP_FORMAT
        end

        def _time_stamp
          @params.date.strftime Jekyll::Compose::DEFAULT_TIMESTAMP_FORMAT
        end

        def content(custom_front_matter = {})
          if jekyll_compose_config && jekyll_compose_config["post_default_front_matter"]
            custom_front_matter.merge!(jekyll_compose_config["post_default_front_matter"])
          end

          super({ "date" => _time_stamp }.merge(custom_front_matter))
        end

        private

        def jekyll_compose_config
          @jekyll_compose_config ||= Jekyll.configuration["jekyll_compose"]
        end
      end
    end
  end
end
