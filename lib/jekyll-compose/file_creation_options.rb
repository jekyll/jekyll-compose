class Jekyll::Compose::FileCreationOptions
  attr_reader :resource_type

  def initialize(resource_type)
    @resource_type = resource_type
  end

  def create_options(command)
    command.option 'type', '-t TYPE', '--type TYPE', 'Specify the content type (file extension)'
    command.option 'layout', '-t LAYOUT', '--layout LAYOUT', "Specify the #{resource_type} layout"
    command.option 'force', '-f', '--force', 'Overwrite a post if it already exists'
  end
end
