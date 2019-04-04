# frozen_string_literal: true

RSpec.describe(Jekyll::Commands::Unpublish) do
  let(:drafts_dir) { Pathname.new(source_dir("_drafts")) }
  let(:posts_dir)  { Pathname.new(source_dir("_posts")) }
  let(:post_name) { "a-test-post.md" }
  let(:timestamp) { Time.now.strftime(Jekyll::Compose::DEFAULT_TIMESTAMP_FORMAT) }
  let(:datestamp) { Time.now.strftime(Jekyll::Compose::DEFAULT_DATESTAMP_FORMAT) }
  let(:post_filename) { "#{datestamp}-#{post_name}" }
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
    File.write(post_path, "---\nlayout: post\ndate: #{timestamp}\n---\n")
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
    expect(File.read(draft_path)).not_to include("date: #{timestamp}")
  end

  it "writes a helpful message on success" do
    expect(post_path).to exist
    output = capture_stdout { described_class.process(args) }
    expect(output).to include("Post _posts/#{post_filename} was moved to _drafts/#{post_name}")
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

  it "outputs a warning and returns if no file exists at given path" do
    weird_path = "_posts/i-forgot-the-date.md"
    output = capture_stdout { described_class.process [weird_path] }
    expect(output).to include("There was no post found at '#{weird_path}'.")
  end

  context "when the draft already exists" do
    let(:args) { ["_posts/#{post_filename}"] }

    before(:each) do
      FileUtils.touch draft_path
    end

    it "displays a warning and returns" do
      output = capture_stdout { described_class.process(args) }
      expect(output).to include("A draft already exists at _drafts/#{post_name}")
      expect(draft_path).to exist
      expect(post_path).to exist
    end

    it "overwrites if --force is given" do
      output = capture_stdout { described_class.process(args, "force" => true) }
      expect(output).to_not include("A draft already exists at _drafts/#{post_name}")
      expect(draft_path).to exist
      expect(post_path).not_to exist
      expect(File.read(draft_path)).not_to include("date: #{timestamp}")
    end
  end

  context "when a configuration file exists" do
    let(:config) { source_dir("_config.yml") }
    let(:drafts_dir) { Pathname.new(source_dir("site", "_drafts")) }
    let(:posts_dir)  { Pathname.new(source_dir("site", "_posts")) }
    let(:config_data) do
      %(
    source: site
    )
    end

    before(:each) do
      File.open(config, "w") do |f|
        f.write(config_data)
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

    context "and collections_dir is set" do
      let(:collections_dir) { "my_collections" }
      let(:drafts_dir) { Pathname.new(source_dir("site", collections_dir, "_drafts")) }
      let(:posts_dir)  { Pathname.new(source_dir("site", collections_dir, "_posts")) }
      let(:config_data) do
        %(
      source: site
      collections_dir: #{collections_dir}
      )
      end

      it "should move posts to the correct location" do
        expect(post_path).to exist
        expect(draft_path).not_to exist
        capture_stdout { described_class.process(args) }
        expect(draft_path).to exist
      end

      it "should write a helpful message when successful" do
        output = capture_stdout { described_class.process(args) }
        post_filepath  = File.join("site", collections_dir, "_posts", post_filename)
        draft_filepath = File.join("site", collections_dir, "_drafts", post_name)
        expect(output).to include("Post #{post_filepath} was moved to #{draft_filepath}")
      end
    end
  end

  context "when source option is set" do
    let(:drafts_dir) { Pathname.new(source_dir("site", "_drafts")) }
    let(:posts_dir)  { Pathname.new(source_dir("site", "_posts")) }

    it "should use source directory set by command line option" do
      expect(post_path).to exist
      expect(draft_path).not_to exist
      capture_stdout { described_class.process(args, "source" => "site") }
      expect(post_path).not_to exist
      expect(draft_path).to exist
    end
  end
end
