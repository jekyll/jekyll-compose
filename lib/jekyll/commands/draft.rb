module Jekyll
  module Commands
    class Draft < Command
      def self.init_with_program(prog)
        prog.command(:draft) do |c|
          c.syntax 'draft NAME'
          c.description 'Creates a new draft post with the given NAME'

          options.each {|opt| c.option *opt }

          c.action { |args, options| process args, options }
        end
      end

      def self.options
        [
          ['extension', '-x EXTENSION', '--extension EXTENSION', 'Specify the file extension'],
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

      class DraftFileInfo < Compose::FileInfo
        def resource_type
          'draft'
        end

        def path
          "_drafts/#{file_name}"
        end
      end
    end
  end
end
