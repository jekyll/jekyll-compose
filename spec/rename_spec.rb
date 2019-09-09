# frozen_string_literal: true

RSpec.describe(Jekyll::Commands::Rename) do
  let(:datestamp) { Time.now.strftime(Jekyll::Compose::DEFAULT_DATESTAMP_FORMAT) }
  let(:timestamp) { Time.now.strftime(Jekyll::Compose::DEFAULT_TIMESTAMP_FORMAT) }

  context "drafts" do
    let(:drafts_dir) { Pathname.new source_dir("_drafts") }
    let(:old_name) { "Old Draft" }
    let(:new_name) { "New Draft" }
    let(:old_filename) { "old-draft.md" }
    let(:new_filename) { "new-draft.md" }
    let(:old_path) { drafts_dir.join(old_filename) }
    let(:new_path) { drafts_dir.join(new_filename) }
    let(:old_arg) { File.join("_drafts", old_filename) }
    let(:new_arg) { File.join("_drafts", new_filename) }
    let(:args) { [old_arg, new_name] }

    before(:all) do
      FileUtils.mkdir_p source_dir unless File.directory? source_dir
      Dir.chdir source_dir
    end

    before(:each) do
      FileUtils.mkdir_p drafts_dir unless File.directory? drafts_dir
      File.write(old_path, "---\nlayout: post\ntitle: Old Draft\n---\n")
    end

    after(:each) do
      FileUtils.rm_r old_path if File.file? old_path
      FileUtils.rm_r new_path if File.file? new_path
      FileUtils.rm_r drafts_dir if File.directory? drafts_dir
    end

    it "moves a draft" do
      expect(old_path).to exist
      expect(new_path).not_to exist
      capture_stdout { described_class.process(args) }
      expect(old_path).not_to exist
      expect(new_path).to exist
    end

    it "changes the title of the draft" do
      expect(old_path).to exist
      expect(new_path).not_to exist
      expect(File.read(old_path)).to match(%r!title: Old Draft!)
      capture_stdout { described_class.process(args) }
      expect(old_path).not_to exist
      expect(new_path).to exist
      expect(File.read(new_path)).to match(%r!title: New Draft!)
    end

    it "should write a helpful message when successful" do
      output = capture_stdout { described_class.process(args) }
      expect(output).to include("Draft #{old_arg} was moved to #{new_arg}")
    end

    it "errors with no arguments" do
      expect(lambda {
        capture_stdout { described_class.process }
      }).to raise_error("You must specify current path and the new title.")
    end

    it "errors with only one argument" do
      expect(lambda {
        capture_stdout { described_class.process([old_path]) }
      }).to raise_error("You must specify current path and the new title.")
    end

    context "when the draft with the new filename already exists" do
      before(:each) do
        FileUtils.touch new_path
      end

      it "displays a warning and returns" do
        output = capture_stdout { described_class.process(args) }
        expect(output).to include("A draft already exists at #{new_arg}")
        expect(output).to_not include("Draft #{old_arg} was moved to #{new_arg}")
        expect(File.read(new_path)).to_not include("layout: post")
      end

      it "overwrites if --force is given" do
        output = capture_stdout { described_class.process(args, "force" => true) }
        expect(output).to_not include("A draft already exists at #{new_arg}")
        expect(output).to include("Draft #{old_arg} was moved to #{new_arg}")
        expect(File.read(new_path)).to include("layout: post")
      end
    end

    context "when a configuration file exists" do
      let(:config) { source_dir("_config.yml") }
      let(:drafts_dir) { Pathname.new source_dir("site", "_drafts") }
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
        expect(new_path).not_to exist
        capture_stdout { described_class.process(args) }
        expect(new_path).to exist
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
          expect(drafts_dir).to exist
          expect(old_path).to exist
          expect(new_path).not_to exist
          capture_stdout { described_class.process(args) }
          expect(drafts_dir).to exist
          expect(old_path).not_to exist
          expect(new_path).to exist
        end

        it "should write a helpful message when successful" do
          output = capture_stdout { described_class.process(args) }
          old_arg = File.join("site", collections_dir, "_drafts", old_filename)
          new_arg = File.join("site", collections_dir, "_drafts", new_filename)
          expect(output).to include("Draft #{old_arg} was moved to #{new_arg}")
        end
      end
    end

    context "when source option is set" do
      let(:drafts_dir) { Pathname.new source_dir("site", "_drafts") }

      it "should use source directory set by command line option" do
        expect(old_path).to exist
        expect(new_path).not_to exist
        capture_stdout { described_class.process(args, "source" => "site") }
        expect(old_path).not_to exist
        expect(new_path).to exist
      end
    end
  end
  context "posts" do
    let(:posts_dir) { Pathname.new source_dir("_posts") }
    let(:old_name) { "Old Post" }
    let(:new_name) { "New Post" }
    let(:old_basename) { "old-post.md" }
    let(:new_basename) { "new-post.md" }
    let(:old_filename) { "#{datestamp}-#{old_basename}" }
    let(:new_filename) { "#{datestamp}-#{new_basename}" }
    let(:old_path) { posts_dir.join(old_filename) }
    let(:new_path) { posts_dir.join(new_filename) }
    let(:old_arg) { File.join("_posts", old_filename) }
    let(:new_arg) { File.join("_posts", new_filename) }
    let(:args) { [old_arg, new_name] }

    before(:all) do
      FileUtils.mkdir_p source_dir unless File.directory? source_dir
      Dir.chdir source_dir
    end

    before(:each) do
      FileUtils.mkdir_p posts_dir unless File.directory? posts_dir
      File.write(old_path, "---\nlayout: post\ntitle: #{old_name}\ndate: #{timestamp}\n---\n")
    end

    after(:each) do
      FileUtils.rm_r old_path if File.file? old_path
      FileUtils.rm_r new_path if File.file? new_path
      FileUtils.rm_r posts_dir if File.directory? posts_dir
    end

    it "moves a post" do
      expect(old_path).to exist
      expect(new_path).not_to exist
      capture_stdout { described_class.process(args) }
      expect(old_path).not_to exist
      expect(new_path).to exist
    end

    it "changes the title of the post" do
      expect(old_path).to exist
      expect(new_path).not_to exist
      expect(File.read(old_path)).to match(%r!title: #{old_name}!)
      capture_stdout { described_class.process(args) }
      expect(old_path).not_to exist
      expect(new_path).to exist
      expect(File.read(new_path)).to match(%r!title: #{new_name}!)
    end

    it "should write a helpful message when successful" do
      output = capture_stdout { described_class.process(args) }
      expect(output).to include("Post #{old_arg} was moved to #{new_arg}")
    end

    it "errors with no arguments" do
      expect(lambda {
        capture_stdout { described_class.process }
      }).to raise_error("You must specify current path and the new title.")
    end

    it "errors with only one argument" do
      expect(lambda {
        capture_stdout { described_class.process([old_path]) }
      }).to raise_error("You must specify current path and the new title.")
    end

    context "with a date argument" do
      let(:new_datestamp) { "2012-03-04" }
      let(:new_filename) { "#{new_datestamp}-#{new_basename}" }

      it "moves a post" do
        expect(old_path).to exist
        expect(new_path).not_to exist
        capture_stdout { described_class.process(args, "date" => new_datestamp) }
        expect(old_path).not_to exist
        expect(new_path).to exist
      end

      it "changes the title of the post" do
        expect(old_path).to exist
        expect(new_path).not_to exist
        expect(File.read(old_path)).to match(%r!title: #{old_name}!)
        capture_stdout { described_class.process(args, "date" => new_datestamp) }
        expect(old_path).not_to exist
        expect(new_path).to exist
        expect(File.read(new_path)).to match(%r!title: #{new_name}!)
      end

      it "changes the date of the post" do
        expect(old_path).to exist
        expect(new_path).not_to exist
        expect(File.read(old_path)).to match(%r!title: #{old_name}!)
        capture_stdout { described_class.process(args, "date" => new_datestamp) }
        expect(old_path).not_to exist
        expect(new_path).to exist
        expect(File.read(new_path)).to match(%r!date: #{new_datestamp}!)
      end

      it "should write a helpful message when successful" do
        output = capture_stdout { described_class.process(args, "date" => new_datestamp) }
        expect(output).to include("Post #{old_arg} was moved to #{new_arg}")
      end
    end

    context "with a now argument" do
      let(:now) { Time.parse("2015-06-07 08:09") }
      let(:old) { Time.parse("2012-03-04 05:06") }
      let(:now_datestamp) { now.strftime(Jekyll::Compose::DEFAULT_DATESTAMP_FORMAT) }
      let(:now_timestamp) { now.strftime(Jekyll::Compose::DEFAULT_TIMESTAMP_FORMAT) }
      let(:datestamp) { old.strftime(Jekyll::Compose::DEFAULT_DATESTAMP_FORMAT) }
      let(:timestamp) { old.strftime(Jekyll::Compose::DEFAULT_TIMESTAMP_FORMAT) }
      let(:new_filename) { "#{now_datestamp}-#{new_basename}" }

      before(:each) do
        FileUtils.mkdir_p posts_dir unless File.directory? posts_dir
        File.write(old_path, "---\nlayout: post\ntitle: #{old_name}\ndate: #{timestamp}\n---\n")
        allow(Time).to receive(:now).and_return(now)
      end

      after(:each) do
        FileUtils.rm_r old_path if File.file? old_path
        FileUtils.rm_r new_path if File.file? new_path
        FileUtils.rm_r posts_dir if File.directory? posts_dir
      end

      it "moves a post" do
        expect(old_path).to exist
        expect(new_path).not_to exist
        capture_stdout { described_class.process(args, "now" => true) }
        expect(old_path).not_to exist
        expect(new_path).to exist
      end

      it "changes the title of the post" do
        expect(old_path).to exist
        expect(new_path).not_to exist
        expect(File.read(old_path)).to match(%r!title: #{old_name}!)
        capture_stdout { described_class.process(args, "now" => true) }
        expect(old_path).not_to exist
        expect(new_path).to exist
        expect(File.read(new_path)).to match(%r!title: #{new_name}!)
      end

      it "changes the date of the post" do
        expect(old_path).to exist
        expect(new_path).not_to exist
        expect(File.read(old_path)).to match(%r!title: #{old_name}!)
        capture_stdout { described_class.process(args, "now" => true) }
        expect(old_path).not_to exist
        expect(new_path).to exist
        expect(File.read(new_path)).to match(%r!date: #{Regexp.quote(now_timestamp)}!)
      end

      it "should write a helpful message when successful" do
        output = capture_stdout { described_class.process(args, "now" => true) }
        expect(output).to include("Post #{old_arg} was moved to #{new_arg}")
      end
    end

    context "when the post with the new filename already exists" do
      before(:each) do
        FileUtils.touch new_path
      end

      it "displays a warning and returns" do
        output = capture_stdout { described_class.process(args) }
        expect(output).to include("A post already exists at #{new_arg}")
        expect(output).to_not include("Post #{old_arg} was moved to #{new_arg}")
        expect(File.read(new_path)).to_not include("layout: post")
      end

      it "overwrites if --force is given" do
        output = capture_stdout { described_class.process(args, "force" => true) }
        expect(output).to_not include("A post already exists at #{new_arg}")
        expect(output).to include("Post #{old_arg} was moved to #{new_arg}")
        expect(File.read(new_path)).to include("layout: post")
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
        expect(new_path).not_to exist
        capture_stdout { described_class.process(args) }
        expect(new_path).to exist
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
          expect(posts_dir).to exist
          expect(old_path).to exist
          expect(new_path).not_to exist
          capture_stdout { described_class.process(args) }
          expect(posts_dir).to exist
          expect(old_path).not_to exist
          expect(new_path).to exist
        end

        it "should write a helpful message when successful" do
          output = capture_stdout { described_class.process(args) }
          old_arg = File.join("site", collections_dir, "_posts", old_filename)
          new_arg = File.join("site", collections_dir, "_posts", new_filename)
          expect(output).to include("Post #{old_arg} was moved to #{new_arg}")
        end
      end
    end

    context "when source option is set" do
      let(:posts_dir) { Pathname.new source_dir("site", "_posts") }

      it "should use source directory set by command line option" do
        expect(old_path).to exist
        expect(new_path).not_to exist
        capture_stdout { described_class.process(args, "source" => "site") }
        expect(old_path).not_to exist
        expect(new_path).to exist
      end
    end
  end
end
