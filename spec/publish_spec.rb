# frozen_string_literal: true

RSpec.describe(Jekyll::Commands::Publish) do
  let(:drafts_dir) { Pathname.new source_dir("_drafts") }
  let(:posts_dir)  { Pathname.new source_dir("_posts") }
  let(:draft_to_publish) { "a-test-post.md" }
  let(:datestamp) { Time.now.strftime("%Y-%m-%d") }
  let(:post_filename) { "#{datestamp}-#{draft_to_publish}" }
  let(:args) { ["_drafts/#{draft_to_publish}"] }

  let(:draft_path) { drafts_dir.join draft_to_publish }
  let(:post_path)  { posts_dir.join post_filename }

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

  it "publishes a draft post" do
    expect(post_path).not_to exist
    expect(draft_path).to exist
    capture_stdout { described_class.process(args) }
    expect(post_path).to exist
  end

  it "publishes with a specified date" do
    path = posts_dir.join "2012-03-04-#{draft_to_publish}"
    expect(path).not_to exist
    capture_stdout { described_class.process(args, { "date"=>"2012-3-4" }) }
    expect(path).to exist
  end

  it "writes a helpful message on success" do
    expect(draft_path).to exist
    output = capture_stdout { described_class.process(args) }
    expect(output).to eql("Draft _drafts/#{draft_to_publish} was moved to _posts/#{post_filename}\n")
  end

  it "publishes a draft on the specified date" do
    path = posts_dir.join "2012-03-04-a-test-post.md"
    capture_stdout { described_class.process(args, { "date" => "2012-3-4" }) }
    expect(path).to exist
  end

  it "creates the posts folder if necessary" do
    FileUtils.rm_r posts_dir if File.directory? posts_dir
    capture_stdout { described_class.process(args) }
    expect(posts_dir).to exist
  end

  it "errors if there is no argument" do
    expect(lambda {
      capture_stdout { described_class.process }
    }).to raise_error("You must specify a draft path.")
  end

  it "errors if no file exists at given path" do
    weird_path = "_drafts/i-do-not-exist.markdown"
    expect(lambda {
      capture_stdout { described_class.process [weird_path] }
    }).to raise_error("There was no draft found at '_drafts/i-do-not-exist.markdown'.")
  end

  context "when the post already exists" do
    let(:args) { ["_drafts/#{draft_to_publish}"] }

    before(:each) do
      FileUtils.touch post_path
    end

    it "raises an error" do
      expect(lambda {
        capture_stdout { described_class.process(args) }
      }).to raise_error("A post already exists at _posts/#{post_filename}")
      expect(draft_path).to exist
      expect(post_path).to exist
    end

    it "overwrites if --force is given" do
      expect(lambda {
        capture_stdout { described_class.process(args, "force" => true) }
      }).not_to raise_error
      expect(draft_path).not_to exist
      expect(post_path).to exist
    end
  end

  context "when a configuration file exists" do
    let(:config) { source_dir("_config.yml") }
    let(:drafts_dir) { Pathname.new source_dir("site", "_drafts") }
    let(:posts_dir)  { Pathname.new source_dir("site", "_posts") }

    let(:args) { ["site/_drafts/#{draft_to_publish}"] }

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
      expect(post_path).not_to exist
      expect(draft_path).to exist
      capture_stdout { described_class.process(args) }
      expect(post_path).to exist
    end
  end

  context "when source option is set" do
    let(:drafts_dir) { Pathname.new source_dir("site", "_drafts") }
    let(:posts_dir)  { Pathname.new source_dir("site", "_posts") }

    let(:args) { ["site/_drafts/#{draft_to_publish}"] }

    it "should use source directory set by command line option" do
      expect(post_path).not_to exist
      expect(draft_path).to exist
      capture_stdout { described_class.process(args, "source" => "site") }
      expect(post_path).to exist
    end
  end
end
