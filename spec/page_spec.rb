# frozen_string_literal: true

RSpec.describe(Jekyll::Commands::Page) do
  let(:name) { "A test page" }
  let(:args) { [name] }
  let(:filename) { "a-test-page.md" }
  let(:path) { Pathname.new(source_dir).join(filename) }

  before(:all) do
    FileUtils.mkdir_p source_dir unless File.directory? source_dir
    Dir.chdir source_dir
  end

  after(:each) do
    FileUtils.rm path if File.exist? path
  end

  it "creates a new page" do
    expect(path).not_to exist
    capture_stdout { described_class.process(args) }
    expect(path).to exist
  end

  it "creates a new page with the specified extension" do
    html_path = Pathname.new(source_dir).join "a-test-page.html"
    FileUtils.rm html_path if File.exist? html_path
    capture_stdout { described_class.process(args, "extension" => "html") }
    expect(html_path).to exist
  end

  it "creates a new page with the specified layout" do
    capture_stdout { described_class.process(args, "layout" => "other-layout") }
    expect(File.read(path)).to match(%r!layout: other-layout!)
  end

  it "should write a helpful message when successful" do
    output = capture_stdout { described_class.process(args) }
    expect(output).to eql("New page created at #{filename}.\n")
  end

  it "errors with no arguments" do
    expect(lambda {
      capture_stdout { described_class.process }
    }).to raise_error("You must specify a name.")
  end

  context "when the page already exists" do
    let(:name) { "An existing page" }
    let(:filename) { "an-existing-page.md" }

    before(:each) do
      FileUtils.touch path
    end

    it "raises an error" do
      expect(lambda {
        capture_stdout { described_class.process(args) }
      }).to raise_error("A page already exists at #{filename}")
    end

    it "overwrites if --force is given" do
      expect(lambda {
        capture_stdout { described_class.process(args, "force" => true) }
      }).not_to raise_error
      expect(File.read(path)).to match(%r!layout: page!)
    end
  end

  context "when a configuration file exists" do
    let(:config) { source_dir("_config.yml") }
    let(:path) { Pathname.new(source_dir).join("site", filename) }

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
    let(:path) { Pathname.new(source_dir).join("site", filename) }

    it "should use source directory set by command line option" do
      expect(path).not_to exist
      capture_stdout { described_class.process(args, "source" => "site") }
      expect(path).to exist
    end
  end
end
