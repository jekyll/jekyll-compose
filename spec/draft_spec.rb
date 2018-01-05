# frozen_string_literal: true

RSpec.describe(Jekyll::Commands::Draft) do
  let(:name) { "A test post" }
  let(:args) { [name] }
  let(:drafts_dir) { Pathname.new source_dir("_drafts") }
  let(:path) { drafts_dir.join("a-test-post.md") }

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

  it "creates a new draft" do
    expect(path).not_to exist
    capture_stdout { described_class.process(args) }
    expect(path).to exist
  end

  it "writes a helpful success message" do
    output = capture_stdout { described_class.process(args) }
    expect(output).to eql("New draft created at _drafts/a-test-post.md.\n")
  end

  it "errors with no arguments" do
    expect(lambda {
      capture_stdout { described_class.process }
    }).to raise_error("You must specify a name.")
  end

  it "creates the drafts folder if necessary" do
    FileUtils.rm_r drafts_dir if File.directory? drafts_dir
    capture_stdout { described_class.process(args) }
    expect(drafts_dir).to exist
  end

  it "creates the draft with a specified extension" do
    html_path = drafts_dir.join "a-test-post.html"
    expect(html_path).not_to exist
    capture_stdout { described_class.process(args, "extension" => "html") }
    expect(html_path).to exist
  end

  it "creates a new draft with the specified layout" do
    capture_stdout { described_class.process(args, "layout" => "other-layout") }
    expect(File.read(path)).to match(%r!layout: other-layout!)
  end

  context "when the draft already exists" do
    let(:name) { "An existing draft" }
    let(:path) { drafts_dir.join("an-existing-draft.md") }

    before(:each) do
      FileUtils.touch path
    end

    it "raises an error" do
      expect(lambda {
        capture_stdout { described_class.process(args) }
      }).to raise_error("A draft already exists at _drafts/an-existing-draft.md")
    end

    it "overwrites if --force is given" do
      expect(lambda {
        capture_stdout { described_class.process(args, "force" => true) }
      }).not_to raise_error
      expect(File.read(path)).to match(%r!layout: post!)
    end
  end

  context "when a configuration file exists" do
    let(:config) { source_dir("_config.yml") }
    let(:drafts_dir) { Pathname.new source_dir(File.join("site", "_drafts")) }

    before(:each) do
      File.open(config, "w") do |f|
        f.write(%(
source: site
))
      end
    end

    after(:each) do
      FileUtils.rm(config)
    end

    it "should use source directory set by config" do
      expect(path).not_to exist
      capture_stdout { described_class.process(args) }
      expect(path).to exist
    end
  end

  context "when source option is set" do
    let(:drafts_dir) { Pathname.new source_dir(File.join("site", "_drafts")) }

    it "should use source directory set by command line option" do
      expect(path).not_to exist
      capture_stdout { described_class.process(args, "source" => "site") }
      expect(path).to exist
    end
  end
end
