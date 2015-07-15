RSpec.describe(Jekyll::Commands::Unpublish) do
  let(:drafts_dir) { Pathname.new(source_dir('_drafts')) }
  let(:posts_dir)  { Pathname.new(source_dir('_posts')) }
  let(:post_name) { "a-test-post.md" }
  let(:post_filename) { "2012-03-04-#{post_name}" }
  let(:post_path) { posts_dir.join post_filename }
  let(:draft_path) { drafts_dir.join post_name }

  let(:args) { ["_posts/#{post_filename}"] }

  before(:all) do
    FileUtils.mkdir_p source_dir unless File.directory? source_dir
    Dir.chdir source_dir
  end

  before(:each) do
    FileUtils.mkdir_p drafts_dir unless File.directory? drafts_dir
    FileUtils.mkdir_p posts_dir unless File.directory? posts_dir
    FileUtils.touch post_path
  end

  after(:each) do
    FileUtils.rm_r drafts_dir if File.directory? drafts_dir
    FileUtils.rm_r posts_dir if File.directory? posts_dir
  end

  it 'moves a post back to _drafts' do
    expect(post_path).to exist
    expect(draft_path).not_to exist
    capture_stdout { described_class.process(args) }
    expect(post_path).not_to exist
    expect(draft_path).to exist
  end

  it 'writes a helpful message on success' do
    expect(post_path).to exist
    output = capture_stdout { described_class.process(args) }
    expect(output).to eql("Post _posts/#{post_filename} was moved to _drafts/#{post_name}\n")
  end

  it 'creates the drafts folder if necessary' do
    FileUtils.rm_r drafts_dir if File.directory? drafts_dir
    capture_stdout { described_class.process(args) }
    expect(drafts_dir).to exist
  end

  it 'errors if there is no argument' do
    expect(-> {
      capture_stdout { described_class.process }
    }).to raise_error('You must specify a post path.')
  end

  it 'errors if no file exists at given path' do
    weird_path = '_posts/i-forgot-the-date.md'
    expect(-> {
      capture_stdout { described_class.process [weird_path] }
    }).to raise_error("There was no post found at '#{weird_path}'.")
  end

end
