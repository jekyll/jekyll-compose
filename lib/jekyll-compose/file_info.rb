class Jekyll::Compose::FileInfo
  attr_reader :params
  def initialize(params)
    @params = params
  end

  def file_name
    name = params.title.gsub(' ', '-').downcase
    "#{name}.#{params.type}"
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
