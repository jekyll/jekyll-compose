class Jekyll::Compose::ArgParser
  attr_reader :args, :options
  def initialize(args, options)
    @args = args
    @options = options
  end

  def validate!
    raise ArgumentError.new('You must specify a name.') if args.empty?
  end

  def type
    type = options["extension"] || Jekyll::Compose::DEFAULT_TYPE
  end

  def layout
    layout = options["layout"] || Jekyll::Compose::DEFAULT_LAYOUT
  end

  def title
    args.join ' '
  end

  def force?
    !!options["force"]
  end
end
