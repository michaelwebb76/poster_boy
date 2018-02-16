# frozen_string_literal: true

require 'spec_helper'

describe PosterBoyArguments do
  let(:poster_boy_arguments) { described_class.new(argv) }

  let(:fixture_template_path) do
    File.dirname(__FILE__).to_s + '/../support/fixtures/post_template.yml.erb'
  end
  let(:fixture_data_path) do
    File.dirname(__FILE__).to_s + '/../support/fixtures/data.csv'
  end

  describe '#executable? and #errors' do
    context 'when no arguments' do
      let(:argv) { [] }

      specify do
        expect(poster_boy_arguments.executable?).to be false
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::BLURB
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::TEMPLATE_REQUIRED
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::DATA_REQUIRED
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::EXECUTE_OPTIONAL
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::MORE_HELP
      end
    end

    context 'when help requested' do
      let(:argv) { ['--help'] }

      specify do
        expect(poster_boy_arguments.executable?).to be false
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::BLURB
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::TEMPLATE_REQUIRED
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::DATA_REQUIRED
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::EXECUTE_OPTIONAL
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::MORE_HELP
      end
    end

    context 'when template given and valid' do
      let(:argv) { ['--template', fixture_template_path] }

      specify do
        expect(poster_boy_arguments.executable?).to be false
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::BLURB
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::TEMPLATE_REQUIRED
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::DATA_REQUIRED
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::EXECUTE_OPTIONAL
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::MORE_HELP
      end
    end

    context 'when data given and valid' do
      let(:argv) { ['--data', fixture_data_path, '--template'] }

      specify do
        expect(poster_boy_arguments.executable?).to be false
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::BLURB
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::TEMPLATE_REQUIRED
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::DATA_REQUIRED
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::EXECUTE_OPTIONAL
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::MORE_HELP
      end
    end

    context 'when template and data given but wrong format for template' do
      let(:argv) { ['--data', fixture_data_path, '--template', fixture_data_path] }

      specify do
        expect(poster_boy_arguments.executable?).to be false
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::BLURB
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::TEMPLATE_REQUIRED
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::DATA_REQUIRED
        expect(poster_boy_arguments.errors).not_to include PosterBoyArguments::EXECUTE_OPTIONAL
        expect(poster_boy_arguments.errors).to include PosterBoyArguments::MORE_HELP
      end
    end

    context 'when template and data given and valid' do
      let(:argv) { ['--data', fixture_data_path, '--template', fixture_template_path] }

      specify do
        expect(poster_boy_arguments.executable?).to be true
        expect(poster_boy_arguments.errors).to be_empty
      end
    end
  end
end
