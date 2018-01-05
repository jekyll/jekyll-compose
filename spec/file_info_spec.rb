# frozen_string_literal: true

RSpec.describe(Jekyll::Compose::FileInfo) do
  before(:all) do
    FileUtils.mkdir_p source_dir unless File.directory? source_dir
    Dir.chdir source_dir
  end

  describe "#content" do
    context "with a title of only words" do
      let(:expected_result) do
        <<-CONTENT.gsub(%r!^\s+!, "")
          ---
          layout: post
          title: A test arg parser
          ---
        CONTENT
      end

      let(:parsed_args) do
        Jekyll::Compose::ArgParser.new(
          ["A test arg parser"],
          {}
        )
      end

      it "does not wrap the title in quotes" do
        file_info = described_class.new parsed_args
        expect(file_info.content).to eq(expected_result)
      end
    end

    context "with a title that includes a colon" do
      let(:expected_result) do
        <<-CONTENT.gsub(%r!^\s+!, "")
          ---
          layout: post
          title: 'A test: arg parser'
          ---
        CONTENT
      end

      let(:parsed_args) do
        Jekyll::Compose::ArgParser.new(
          ["A test: arg parser"],
          {}
        )
      end

      it "does wrap the title in quotes" do
        file_info = described_class.new parsed_args
        expect(file_info.content).to eq(expected_result)
      end
    end

    context "with custom values" do
      let(:expected_result) do
        <<-CONTENT.gsub(%r!^\s+!, "")
          ---
          layout: post
          title: A test
          foo: bar
          ---
        CONTENT
      end

      let(:parsed_args) do
        Jekyll::Compose::ArgParser.new(
          ["A test arg parser"],
          {}
        )
      end

      it "does not wrap the title in quotes" do
        file_info = described_class.new parsed_args
        expect(file_info.content("title" => "A test", "foo" => "bar")).to eq(expected_result)
      end
    end
  end
end
