# frozen_string_literal: true

require 'csv'
require 'highline/import'

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
      output << if @poster_boy_arguments.execute?
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
      @template_yml_hash = YAML.load(template_yml)
    end

    def execute
    end

    def dry_run_output
      [
        "#{method} #{target_url}",
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
      @template_yml_hash['headers']
    end

    def parameters
      @template_yml_hash['parameters']
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
