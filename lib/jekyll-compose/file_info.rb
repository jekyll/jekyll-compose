class Jekyll::Compose::FileInfo
  attr_reader :params
  def initialize(params)
    @params = params
  end

  def file_name
    name = Jekyll::Utils.slugify params.title
    "#{name}.#{params.type}"
  end

  def content
    <<-CONTENT.gsub /^\s+/, ''
      ---
      layout: #{params.layout}
      title: #{yaml_clean_title}
      ---
    CONTENT
  end

  private

  def yaml_clean_title
    if params.title.include? ':'
      '"' + params.title + '"'
    else
      params.title
    end
  end
end
