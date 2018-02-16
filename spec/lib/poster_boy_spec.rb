# frozen_string_literal: true

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

    context 'when execute not specified' do
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

    context 'when execute specified' do
      let(:execute?) { true }

      before do
        response = instance_double(HTTParty::Response, code: 200, body: 'OK')
        first_options = {
          headers: { 'name' => 'mike' },
          body: { 'api_token' => secret, 'request_body' => '<h1>Get some stuff</h1>' }
        }
        expect(HTTParty)
          .to receive(:post).with('https://an.url', first_options).and_return(response)

        second_options = {
          headers: { 'name' => 'john' },
          body: { 'api_token' => secret, 'request_body' => '<h2>Don\'t get some stuff</h2>' }
        }
        expect(HTTParty)
          .to receive(:post).with('https://an.url', second_options).and_return(response)
      end

      specify do
        expect(execute[0]).to eq 'POST https://an.url'
        expect(execute[1]).to eq 'HEADERS: {"name"=>"mike"}'
        expect(execute[2])
          .to eq "PARAMETERS: {\"api_token\"=>\"#{secret}\", " \
                 '"request_body"=>"<h1>Get some stuff</h1>"}'
        expect(execute[3]).to eq 'RESPONSE CODE: 200'
        expect(execute[4]).to eq 'RESPONSE BODY: OK'
        expect(execute[5]).to eq ''
        expect(execute[6]).to eq 'POST https://an.url'
        expect(execute[7]).to eq 'HEADERS: {"name"=>"john"}'
        expect(execute[8])
          .to eq "PARAMETERS: {\"api_token\"=>\"#{secret}\", " \
                 '"request_body"=>"<h2>Don\'t get some stuff</h2>"}'
        expect(execute[9]).to eq 'RESPONSE CODE: 200'
        expect(execute[10]).to eq 'RESPONSE BODY: OK'
        expect(execute[11]).to eq ''
      end
    end
  end
end
