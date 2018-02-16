# frozen_string_literal: true

require 'csv'
require 'highline/import'
require 'httparty'

class PosterBoy
  def self.execute(poster_boy_arguments)
    new(poster_boy_arguments).execute
  end

  def initialize(poster_boy_arguments)
    @poster_boy_arguments = poster_boy_arguments
    @memoized_asks = {}
  end

  def execute
    output = []
    CSV.foreach(@poster_boy_arguments.data_file, headers: true) do |csv_row|
      api_request = api_request_for_csv_row(csv_row)
      output << if @poster_boy_arguments.request_actual_execution?
                  api_request.execute
                else
                  api_request.dry_run_output
                end
    end
    output.compact.flatten
  end

  private

  def api_request_for_csv_row(csv_row)
    template_yml = template_yml_for_csv_row(csv_row)
    ApiRequest.new(template_yml)
  end

  def template_yml_for_csv_row(csv_row)
    template_yml_erb = File.open(@poster_boy_arguments.template_file, 'rb', &:read)
    view = View.new(csv_row, @memoized_asks)
    ERB.new(template_yml_erb).result(view.view_binding)
  end

  class ApiRequest
    def initialize(template_yml)
      @template_yml_hash = YAML.safe_load(template_yml)
    end

    def execute
      response = case method.upcase
                 when 'GET'
                   HTTParty.get(target_url, request_options)
                 when 'POST'
                   HTTParty.post(target_url, request_options)
                 when 'PATCH'
                   HTTParty.patch(target_url, request_options)
                 when 'PUT'
                   HTTParty.put(target_url, request_options)
                 when 'DELETE'
                   HTTParty.delete(target_url, request_options)
                 when 'HEAD'
                   HTTParty.head(target_url, request_options)
                 when 'OPTIONS'
                   HTTParty.options(target_url, request_options)
                 else
                   raise "unknown request method #{method}"
                 end
      execution_output(response)
    end

    def dry_run_output
      [
        "#{method} #{target_url}",
        ("BASIC AUTHENTICATION: #{basic_authentication}" if basic_authentication.length.positive?),
        ("HEADERS: #{headers}" if headers.length.positive?),
        ("PARAMETERS: #{parameters}" if parameters.length.positive?),
        ''
      ].compact
    end

    private

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

    def request_options
      hash = {}
      hash[:headers] = headers if headers.length.positive?
      hash[:body] = parameters if parameters.length.positive?
      hash[:basic_auth] = basic_authentication if basic_authentication.length.positive?
      hash
    end

    def execution_output(response)
      dry_run_output[0..-2] + [
        "RESPONSE CODE: #{response.code}",
        "RESPONSE BODY: #{response.body}",
        ''
      ]
    end
  end

  class View
    attr_reader :csv_row, :memoized_asks

    def initialize(csv_row, memoized_asks)
      @csv_row = csv_row
      @memoized_asks = memoized_asks
    end

    def prompt_for_secret_data(prompt_string)
      @memoized_asks[prompt_string] ||= ask(prompt_string)
    end

    def view_binding
      binding
    end
  end
end
