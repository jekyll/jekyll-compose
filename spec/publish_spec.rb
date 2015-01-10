RSpec.describe(Jekyll::Commands::Publish) do
  let(:drafts_dir) { source_dir('_drafts') }
  let(:posts_dir)  { source_dir('_posts') }
  let(:draft_to_publish) { 'a-test-post.markdown' }
  let(:post_filename) { "#{Time.now.strftime('%Y-%m-%d')}-#{draft_to_publish}" }
  let(:args) { ["_drafts/#{draft_to_publish}"] }

  let(:draft_path) { Pathname.new(File.join(drafts_dir, draft_to_publish)) }
  let(:post_path)  { Pathname.new(File.join(posts_dir, post_filename))}

  before(:all) do
    FileUtils.mkdir_p source_dir unless File.directory? source_dir
    Dir.chdir source_dir
  end

  before(:each) do
    FileUtils.mkdir_p drafts_dir unless File.directory? drafts_dir
    FileUtils.mkdir_p posts_dir unless File.directory? posts_dir
    FileUtils.touch draft_path
  end

  after(:each) do
    FileUtils.rm_r drafts_dir if File.directory? drafts_dir
    FileUtils.rm_r posts_dir if File.directory? posts_dir
    FileUtils.rm_r draft_path if File.file? draft_path
    FileUtils.rm_r post_path if File.file? post_path
  end

  it 'publishes a draft post' do
    expect(Pathname.new(post_path)).not_to exist
    expect(Pathname.new(draft_path)).to exist
    capture_stdout { described_class.process(args) }
    expect(Pathname.new(post_path)).to exist
  end

  it 'writes a helpful message on success' do
    expect(Pathname.new(draft_path)).to exist
    output = capture_stdout { described_class.process(args) }
    expect(output).to eql("Draft _drafts/#{draft_to_publish} was published to ./_posts/#{post_filename}\n")
  end

  it 'errors if there is no argument' do
    expect(-> {
      capture_stdout { described_class.process }
    }).to raise_error('You must specify a draft path.')
  end

  it 'errors if no file exists at given path' do
    weird_path = '_drafts/i-do-not-exist.markdown'
    expect(-> {
      capture_stdout { described_class.process [weird_path] }
    }).to raise_error("There was no draft found at '_drafts/i-do-not-exist.markdown'.")
  end

end
