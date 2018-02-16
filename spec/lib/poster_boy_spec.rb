# frozen_string_literal

require 'spec_helper'

describe PosterBoy do
  let(:poster_boy) { described_class.new(poster_boy_arguments) }

  let(:poster_boy_arguments) do
    instance_double(
      PosterBoyArguments,
      template_file: fixture_template_path,
      data_file: fixture_data_path,
      execute?: execute?
    )
  end

  let(:fixture_template_path) do
    File.dirname(__FILE__).to_s + '/../support/fixtures/post_template.yml.erb'
  end
  let(:fixture_data_path) do
    File.dirname(__FILE__).to_s + '/../support/fixtures/data.csv'
  end
  let(:execute?) { false }

  describe '#execute' do
    subject(:execute) { poster_boy.execute }

    let(:secret) { 'the secret thing' }

    before do
      allow_any_instance_of(PosterBoy::View).to receive(:ask).and_return(secret)
    end

    specify do
      expect(execute[0]).to eq 'POST https://an.url'
      expect(execute[1]).to eq 'HEADERS: {"name"=>"mike"}'
      expect(execute[2])
        .to eq "PARAMETERS: {\"api_token\"=>\"#{secret}\", " \
               '"request_body"=>"<h1>Get some stuff</h1>"}'
      expect(execute[3]).to eq ''
      expect(execute[4]).to eq 'POST https://an.url'
      expect(execute[5]).to eq 'HEADERS: {"name"=>"john"}'
      expect(execute[6])
        .to eq "PARAMETERS: {\"api_token\"=>\"#{secret}\", " \
               '"request_body"=>"<h2>Don\'t get some stuff</h2>"}'
      expect(execute[7]).to eq ''
    end
  end
end
