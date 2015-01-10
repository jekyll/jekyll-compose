RSpec.describe(Jekyll::Commands::Draft) do
  let(:name) { 'A test post' }
  let(:args) { [name] }
  let(:drafts_dir) { Pathname.new source_dir('_drafts') }
  let(:path) { drafts_dir.join('a-test-post.md') }

  before(:all) do
    FileUtils.mkdir_p source_dir unless File.directory? source_dir
    Dir.chdir source_dir
  end

  before(:each) do
    FileUtils.mkdir_p drafts_dir unless File.directory? drafts_dir
  end

  after(:each) do
    FileUtils.rm_r drafts_dir if File.directory? drafts_dir
  end

  it 'creates a new draft' do
    expect(path).not_to exist
    capture_stdout { described_class.process(args) }
    expect(path).to exist
  end

  it 'writes a helpful success message' do
    output = capture_stdout { described_class.process(args) }
    expect(output).to eql("New draft created at ./_drafts/a-test-post.md.\n")
  end

  it 'errors with no arguments' do
    expect(-> {
      capture_stdout { described_class.process }
    }).to raise_error('You must specify a name.')
  end

  context 'when the draft already exists' do
    let(:name) { 'An existing draft' }
    let(:path) { drafts_dir.join('an-existing-draft.md') }

    before(:each) do
      FileUtils.touch path
    end

    it 'raises an error' do
      expect(-> {
        capture_stdout { described_class.process(args) }
      }).to raise_error("A draft already exists at ./_drafts/an-existing-draft.md")
    end

    it 'overwrites if --force is given' do
      expect(-> {
        capture_stdout { described_class.process(args, 'force' => true) }
      }).not_to raise_error
      expect(File.read(path)).to match(/layout: post/)
    end
  end
end
