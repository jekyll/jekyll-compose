# frozen_string_literal: true

RSpec.describe(Jekyll::Commands::Post) do
  let(:name) { "A test post" }
  let(:args) { [name] }
  let(:posts_dir) { Pathname.new source_dir("_posts") }
  let(:datestamp) { Time.now.strftime(Jekyll::Compose::DEFAULT_DATESTAMP_FORMAT) }
  let(:timestamp) { Time.now.strftime(Jekyll::Compose::DEFAULT_TIMESTAMP_FORMAT) }
  let(:filename) { "#{datestamp}-a-test-post.md" }
  let(:path) { posts_dir.join(filename) }

  before(:all) do
    FileUtils.mkdir_p source_dir unless File.directory? source_dir
    Dir.chdir source_dir
  end

  before(:each) do
    FileUtils.mkdir_p posts_dir unless File.directory? posts_dir
    allow(Jekyll::Compose::FileEditor).to receive(:system)
  end

  after(:each) do
    FileUtils.rm_r posts_dir if File.directory? posts_dir
  end

  it "creates a new post" do
    expect(path).not_to exist
    capture_stdout { described_class.process(args) }
    expect(path).to exist
  end

  it "creates a post with a specified date" do
    path = posts_dir.join "2012-03-04-a-test-post.md"
    expect(path).not_to exist
    capture_stdout { described_class.process(args, "date" => "2012-3-4") }
    expect(path).to exist
    expect(File.read(path)).to match(%r!date: 2012-03-04 00:00 \+0000!)
  end

  it "creates the post with a specified extension" do
    html_path = posts_dir.join "#{datestamp}-a-test-post.html"
    expect(html_path).not_to exist
    capture_stdout { described_class.process(args, "extension" => "html") }
    expect(html_path).to exist
  end

  it "creates a new post with the specified layout" do
    capture_stdout { described_class.process(args, "layout" => "other-layout") }
    expect(File.read(path)).to match(%r!layout: other-layout!)
  end

  it "should write a helpful message when successful" do
    output = capture_stdout { described_class.process(args) }
    expect(output).to include("New post created at #{File.join("_posts", filename).cyan}")
  end

  it "errors with no arguments" do
    expect(lambda {
      capture_stdout { described_class.process }
    }).to raise_error("You must specify a name.")
  end

  it "creates the posts folder if necessary" do
    FileUtils.rm_r posts_dir if File.directory? posts_dir
    capture_stdout { described_class.process(args) }
    expect(posts_dir).to exist
  end

  context "when the post already exists" do
    let(:name) { "An existing post" }
    let(:filename) { "#{datestamp}-an-existing-post.md" }

    before(:each) do
      FileUtils.touch path
    end

    it "displays a warning and returns" do
      output = capture_stdout { described_class.process(args) }
      expect(output).to include("A post already exists at _posts/#{filename}")
      expect(File.read(path)).to_not match("layout: post")
    end

    it "overwrites if --force is given" do
      output = capture_stdout { described_class.process(args, "force" => true) }
      expect(output).to_not include("A post already exists at _posts/#{filename}")
      expect(File.read(path)).to match("layout: post")
    end
  end

  context "when a configuration file exists" do
    let(:config) { source_dir("_config.yml") }
    let(:posts_dir) { Pathname.new source_dir("site", "_posts") }
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
      let(:posts_dir) { Pathname.new source_dir("_posts") }
      let(:config_data) do
        %(
      jekyll_compose:
        auto_open: true
        default_front_matter:
          posts:
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

        context "env variable VISUAL is set up" do
          before { ENV["VISUAL"] = "nano" }

          it "opens post in jekyll editor" do
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
    end

    context "and collections_dir is set" do
      let(:collections_dir) { "my_collections" }
      let(:posts_dir) { Pathname.new source_dir("site", collections_dir, "_posts") }
      let(:config_data) do
        %(
      source: site
      collections_dir: #{collections_dir}
      )
      end

      it "should create posts at the correct location" do
        expect(path).not_to exist
        capture_stdout { described_class.process(args) }
        expect(path).to exist
      end

      it "should write a helpful message when successful" do
        output = capture_stdout { described_class.process(args) }
        generated_path = File.join("site", collections_dir, "_posts", filename).cyan
        expect(output).to include("New post created at #{generated_path}")
      end
    end
  end

  context "when source option is set" do
    let(:posts_dir) { Pathname.new source_dir("site", "_posts") }

    it "should use source directory set by command line option" do
      expect(path).not_to exist
      capture_stdout { described_class.process(args, "source" => "site") }
      expect(path).to exist
    end
  end
end
