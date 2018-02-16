# frozen_string_literal: true

require 'spec_helper'

describe HTTPartyRequestOptions do
  let(:options) { described_class.new(template_yml_hash) }

  let(:template_yml_hash) do
    {
      'method' => 'PUT',
      'target_url' => 'https://an.url',
      'headers' => { 'name' => 'bob' },
      'basic_authentication' => basic_authentication,
      'parameters' => { 'api_token' => 'abc123', 'data' => 'smelly' }
    }
  end
  let(:basic_authentication) { { 'username' => 'bob', 'password' => 'password123' } }

  specify do
    expect(options.method).to eq 'PUT'
    expect(options.target_url).to eq 'https://an.url'
    expect(options.headers).to eq('name' => 'bob')
    expect(options.basic_authentication).to eq('username' => 'bob', 'password' => 'password123')
    expect(options.parameters).to eq('api_token' => 'abc123', 'data' => 'smelly')
  end

  describe '#to_h' do
    specify do
      expect(options.to_h).to eq(
        basic_auth: {
          'username' => 'bob',
          'password' => 'password123'
        },
        body: {
          'api_token' => 'abc123',
          'data' => 'smelly'
        },
        headers: { 'name' => 'bob' }
      )
    end

    context 'when basic auth not specified' do
      let(:basic_authentication) { nil }

      specify do
        expect(options.to_h).to eq(
          body: {
            'api_token' => 'abc123',
            'data' => 'smelly'
          },
          headers: { 'name' => 'bob' }
        )
      end
    end
  end

  describe '#display_lines' do
    specify do
      expect(options.display_lines).to eq [
        'PUT https://an.url',
        'BASIC AUTHENTICATION: {"username"=>"bob", "password"=>"password123"}',
        'HEADERS: {"name"=>"bob"}',
        'PARAMETERS: {"api_token"=>"abc123", "data"=>"smelly"}',
        ''
      ]
    end

    context 'when basic auth not specified' do
      let(:basic_authentication) { nil }

      specify do
        expect(options.display_lines).to eq [
          'PUT https://an.url',
          'HEADERS: {"name"=>"bob"}',
          'PARAMETERS: {"api_token"=>"abc123", "data"=>"smelly"}',
          ''
        ]
      end
    end
  end
end
