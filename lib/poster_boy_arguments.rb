# frozen_string_literal: true

class PosterBoyArguments
  BLURB = 'PosterBoy is a tool you give a request template to, and a CSV, and it will attempt ' \
          'to generate a request for each line in the CSV.'
  TEMPLATE_REQUIRED = 'REQUIRED: --template my-template-file.yml.erb (must be *.yml.erb)'
  DATA_REQUIRED = 'REQUIRED: --data my-data.csv (must be *.csv)'
  EXECUTE_OPTIONAL = 'OPTIONAL: --execute (actually execute the requests)'
  MORE_HELP = 'For full help documentation, use --help'

  def initialize(argv)
    @argv = argv
  end

  def executable?
    errors.length.zero?
  end

  def errors
    @errors ||= begin
      tmp_errors = []
      tmp_errors << BLURB if help_requested?
      tmp_errors << TEMPLATE_REQUIRED if help_requested? || template_file.nil?
      tmp_errors << DATA_REQUIRED if help_requested? || data_file.nil?
      tmp_errors << EXECUTE_OPTIONAL if help_requested?
      tmp_errors << MORE_HELP unless help_requested? || tmp_errors.empty?
      tmp_errors.compact
    end
  end

  def template_file
    @template_file ||= file_of_valid_type_from_arg('--template', '.yml.erb')
  end

  def data_file
    @data_file ||= file_of_valid_type_from_arg('--data', '.csv')
  end

  def execute?
    @argv.include?('--execute')
  end

  private

  def help_requested?
    @argv.include?('--help')
  end

  def file_of_valid_type_from_arg(argument, extension)
    arg_index = @argv.index(argument)
    return nil if arg_index.nil? || arg_index.negative?
    file_path = @argv[arg_index + 1]
    start_extension_index = extension.length * -1
    return nil if file_path.nil? || file_path[start_extension_index..-1] != extension ||
                  !File.exist?(file_path)
    file_path
  end
end
