# frozen_string_literal: true

class HTTPartyRequestOptions
  def initialize(template_yml_hash)
    @template_yml_hash = template_yml_hash
  end

  def to_h
    hash = {}
    hash[:headers] = headers if headers?
    hash[:body] = parameters.to_json if parameters?
    hash[:basic_auth] = basic_authentication if basic_authentication?
    hash
  end

  def display_lines
    [
      "#{method} #{target_url}",
      ("BASIC AUTHENTICATION: #{basic_authentication}" if basic_authentication?),
      ("HEADERS: #{headers}" if headers?),
      ("PARAMETERS: #{parameters}" if parameters?),
      ''
    ].compact
  end

  def method
    @template_yml_hash['method']
  end

  def target_url
    @template_yml_hash['target_url']
  end

  def headers
    @template_yml_hash['headers'] || {}
  end

  def parameters
    @template_yml_hash['parameters'] || {}
  end

  def basic_authentication
    @template_yml_hash['basic_authentication'] || {}
  end

  private

  def headers?
    headers.length.positive?
  end

  def parameters?
    parameters.length.positive?
  end

  def basic_authentication?
    basic_authentication.length.positive?
  end
end
