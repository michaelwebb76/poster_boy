# frozen_string_literal: true

require 'csv'
require 'highline/import'
require 'httparty'
require 'httparty_request_options'

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
      method = request_options.method
      target_url = request_options.target_url
      options = request_options.to_h
      response = case method.upcase
                 when 'GET'
                   HTTParty.get(target_url, options)
                 when 'POST'
                   HTTParty.post(target_url, options)
                 when 'PATCH'
                   HTTParty.patch(target_url, options)
                 when 'PUT'
                   HTTParty.put(target_url, options)
                 when 'DELETE'
                   HTTParty.delete(target_url, options)
                 when 'HEAD'
                   HTTParty.head(target_url, options)
                 when 'OPTIONS'
                   HTTParty.options(target_url, options)
                 else
                   raise "unknown request method #{method}"
                 end
      execution_output(response)
    end

    def dry_run_output
      request_options.display_lines
    end

    private

    def request_options
      @request_options ||= HTTPartyRequestOptions.new(@template_yml_hash)
    end

    def execution_output(response)
      request_options.display_lines[0..-2] + [
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
