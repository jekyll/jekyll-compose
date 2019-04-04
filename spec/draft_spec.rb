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
    allow(Jekyll::Compose::FileEditor).to receive(:system)
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
    expect(output).to include("New draft created at #{"_drafts/a-test-post.md".cyan}")
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

    it "displays a warning and returns" do
      output = capture_stdout { described_class.process(args) }
      expect(output).to include("A draft already exists at _drafts/an-existing-draft.md")
      expect(File.read(path)).to_not match("layout: post")
    end

    it "overwrites if --force is given" do
      output = capture_stdout { described_class.process(args, "force" => true) }
      expect(output).to_not include("A draft already exists at _drafts/an-existing-draft.md")
      expect(File.read(path)).to match("layout: post")
    end
  end

  context "when a configuration file exists" do
    let(:config) { source_dir("_config.yml") }
    let(:drafts_dir) { Pathname.new source_dir(File.join("site", "_drafts")) }
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
      expect(path).not_to exist
      capture_stdout { described_class.process(args) }
      expect(path).to exist
    end

    context "configuration is set" do
      let(:drafts_dir) { Pathname.new source_dir("_drafts") }
      let(:config_data) do
        %(
      jekyll_compose:
        auto_open: true
        draft_default_front_matter:
          description: my description
          category:
      )
      end

      it "creates post with the specified config" do
        capture_stdout { described_class.process(args) }
        post = File.read(path)
        expect(post).to match(%r!description: my description!)
        expect(post).to match(%r!category: !)
      end

      context "env variable EDITOR is set up" do
        before { ENV["EDITOR"] = "nano" }

        it "opens post in default editor" do
          expect(Jekyll::Compose::FileEditor).to receive(:run_editor).with("nano", path.to_s)
          capture_stdout { described_class.process(args) }
        end

        context "env variable JEKYLL_EDITOR is set up" do
          before { ENV["JEKYLL_EDITOR"] = "nano" }

          it "opens post in jekyll editor" do
            expect(Jekyll::Compose::FileEditor).to receive(:run_editor).with("nano", path.to_s)
            capture_stdout { described_class.process(args) }
          end
        end
      end
    end

    context "and collections_dir is set" do
      let(:collections_dir) { "my_collections" }
      let(:drafts_dir) { Pathname.new source_dir("site", collections_dir, "_drafts") }
      let(:config_data) do
        %(
      source: site
      collections_dir: #{collections_dir}
      )
      end

      it "should create drafts at the correct location" do
        expect(path).not_to exist
        capture_stdout { described_class.process(args) }
        expect(path).to exist
      end

      it "should write a helpful message when successful" do
        output = capture_stdout { described_class.process(args) }
        generated_path = File.join("site", collections_dir, "_drafts", "a-test-post.md").cyan
        expect(output).to include("New draft created at #{generated_path}")
      end
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
