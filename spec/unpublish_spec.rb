# frozen_string_literal: true

RSpec.describe(Jekyll::Commands::Unpublish) do
  let(:drafts_dir) { Pathname.new(source_dir("_drafts")) }
  let(:posts_dir)  { Pathname.new(source_dir("_posts")) }
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

  it "moves a post back to _drafts" do
    expect(post_path).to exist
    expect(draft_path).not_to exist
    capture_stdout { described_class.process(args) }
    expect(post_path).not_to exist
    expect(draft_path).to exist
  end

  it "writes a helpful message on success" do
    expect(post_path).to exist
    output = capture_stdout { described_class.process(args) }
    expect(output).to eql("Post _posts/#{post_filename} was moved to _drafts/#{post_name}\n")
  end

  it "creates the drafts folder if necessary" do
    FileUtils.rm_r drafts_dir if File.directory? drafts_dir
    capture_stdout { described_class.process(args) }
    expect(drafts_dir).to exist
  end

  it "errors if there is no argument" do
    expect(lambda {
      capture_stdout { described_class.process }
    }).to raise_error("You must specify a post path.")
  end

  it "errors if no file exists at given path" do
    weird_path = "_posts/i-forgot-the-date.md"
    expect(lambda {
      capture_stdout { described_class.process [weird_path] }
    }).to raise_error("There was no post found at '#{weird_path}'.")
  end

  context "when the draft already exists" do
    let(:args) { ["_posts/#{post_filename}"] }

    before(:each) do
      FileUtils.touch draft_path
    end

    it "raises an error" do
      expect(lambda {
        capture_stdout { described_class.process(args) }
      }).to raise_error("A draft already exists at _drafts/#{post_name}")
      expect(draft_path).to exist
      expect(post_path).to exist
    end

    it "overwrites if --force is given" do
      expect(lambda {
        capture_stdout { described_class.process(args, "force" => true) }
      }).not_to raise_error
      expect(draft_path).to exist
      expect(post_path).not_to exist
    end
  end

  context "when a configuration file exists" do
    let(:config) { source_dir("_config.yml") }
    let(:drafts_dir) { Pathname.new(source_dir("site", "_drafts")) }
    let(:posts_dir)  { Pathname.new(source_dir("site", "_posts")) }

    let(:args) { ["site/_posts/#{post_filename}"] }

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
      expect(post_path).to exist
      expect(draft_path).not_to exist
      capture_stdout { described_class.process(args) }
      expect(post_path).not_to exist
      expect(draft_path).to exist
    end
  end

  context "when source option is set" do
    let(:drafts_dir) { Pathname.new(source_dir("site", "_drafts")) }
    let(:posts_dir)  { Pathname.new(source_dir("site", "_posts")) }

    let(:args) { ["site/_posts/#{post_filename}"] }

    it "should use source directory set by command line option" do
      expect(post_path).to exist
      expect(draft_path).not_to exist
      capture_stdout { described_class.process(args, "source" => "site") }
      expect(post_path).not_to exist
      expect(draft_path).to exist
    end
  end
end
