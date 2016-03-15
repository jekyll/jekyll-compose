RSpec.describe(Jekyll::Compose::FileInfo) do
  describe '#content' do
    context 'with a title of only words' do
      let(:expected_result) {<<-CONTENT.gsub(/^\s+/, '')
          ---
          layout: post
          title: A test arg parser
          ---
        CONTENT
      }

      let(:parsed_args) { Jekyll::Compose::ArgParser.new(
          ['A test arg parser'],
          {}
        )
      }

      it 'does not wrap the title in quotes' do
        file_info = described_class.new parsed_args
        expect(file_info.content).to eq(expected_result)
      end
    end

    context 'with a title that includes a colon' do
      let(:expected_result) {<<-CONTENT.gsub(/^\s+/, '')
          ---
          layout: post
          title: "A test: arg parser"
          ---
        CONTENT
      }

      let(:parsed_args) { Jekyll::Compose::ArgParser.new(
          ['A test: arg parser'],
          {}
        )
      }

      it 'does wrap the title in quotes' do
        file_info = described_class.new parsed_args
        expect(file_info.content).to eq(expected_result)
      end
    end
  end
end

