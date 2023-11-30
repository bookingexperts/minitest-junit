require 'minitest/junit'

# :nodoc:
module Minitest
  def self.plugin_junit_options(opts, options)
    opts.on '--junit', 'Generate a junit xml report' do
      options[:junit] = true
    end
    opts.on '--junit-filename=OUT', 'Target output filename.'\
                                    ' Defaults to report.xml' do |out|
      options[:junit_filename] = out
    end
    opts.on '--junit-jenkins', 'Sanitize test names for Jenkins display' do
      options[:junit_jenkins] = true
    end
  end

  def self.plugin_junit_init(options)
    return unless options.delete :junit
    file_klass = options.delete(:file_klass) || File
    filename = options.delete(:junit_filename) || 'report.xml'

    # Use separate files when running tests in parallel
    if (test_env_number = ENV.fetch('TEST_ENV_NUMBER', nil))
      test_env_number = test_env_number.presence || 1

      filename =
        # Turns /tmp/report.xml into /tmp/report_2.xml if test_env_number is 2
        if (extname = File.extname(filename))
          dirname = File.dirname(filename)
          basename = File.basename(filename, extname)

          File.join(dirname, "#{basename}_#{test_env_number}.#{extname}")
        # Turns /tmp/report into tmp/report_2 if test_env_number is 2
        else
          "#{filename}_#{test_env_number}"
        end
    end

    io = file_klass.new filename, 'w'
    reporter << Junit::Reporter.new(io, options)
  end
end
