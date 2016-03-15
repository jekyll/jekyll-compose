RSpec.describe(Jekyll::Compose::FileInfo) do
  let(:open_and_closing_tag) { "---\n" }
  let(:layout_content) { "post\n" }

  describe '#content' do
    context 'with a title of only words' do
      let(:expected_title) { "A test arg parser\n" }
      subject { described_class.new Jekyll::Compose::ArgParser.new(
          ['A test arg parser'],
          {}
        )
      }

      it 'does not wrap the title in quotes' do
        expect(subject.content).to start_with(open_and_closing_tag)
        expect(subject.content).to end_with(open_and_closing_tag)
        expect(subject.content).to match(layout_content)
        expect(subject.content).to match(expected_title)
      end
    end

    context 'with a title that includes a colon' do
      let(:expected_title) { "'A test: arg parser'\n" }
      subject { described_class.new Jekyll::Compose::ArgParser.new(
          ['A test: arg parser'],
          {}
        )
      }

      it 'does wrap the title in quotes' do
        expect(subject.content).to start_with(open_and_closing_tag)
        expect(subject.content).to end_with(open_and_closing_tag)
        expect(subject.content).to match(layout_content)
        expect(subject.content).to match(expected_title)
      end
    end
  end
end

