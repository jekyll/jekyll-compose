module Jekyll
  module Commands
    class Draft < Command
      def self.init_with_program(prog)
        prog.command(:draft) do |c|
          c.syntax syntax
          c.description description

          options.each {|opt| c.option *opt }

          c.action { |args, options| process args, options }
        end
      end

      def self.syntax
        'draft NAME'
      end

      def self.description
        'Creates a new draft post with the given NAME'
      end

      def self.options
        [
          ['type', '-t TYPE', '--type TYPE', 'Specify the content type (file extension)'],
          ['layout', '-l LAYOUT', '--layout LAYOUT', "Specify the draft layout"],
          ['force', '-f', '--force', 'Overwrite a draft if it already exists']
        ]
      end


      def self.process(args = [], options = {})
        params = Compose::ArgParser.new args, options
        params.validate!

        draft = DraftFileInfo.new params

        Compose::FileCreator.new(draft, params.force?).create!
      end

      class DraftFileInfo
        attr_reader :params
        def initialize(params)
          @params = params
        end

        def resource_type
          'draft'
        end

        def path
          dashing_title = params.title.gsub(' ', '-').downcase
          "_drafts/#{dashing_title}.#{params.type}"
        end

        def content
          <<-CONTENT.gsub /^\s+/, ''
            ---
            layout: #{params.layout}
            title: #{params.title}
            ---
          CONTENT
        end
      end
    end
  end
end
