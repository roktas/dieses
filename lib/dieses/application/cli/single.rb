# frozen_string_literal: true

module Dieses
  module Application
    module CLI
      module Single
        def self.call(*argv, **options)
          options = OpenStruct.new(options)
          args options(argv, options), argv

          sheet = argv.first

          return puts(out = Application.produce(sheet, **options.to_h)) unless options[:output]

          File.write(options[:output], out)
        rescue OptionParser::InvalidOption, Dieses::Error => e
          abort(e.message)
        end

        class << self
          private

          # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          # codebeat:disable[LOC]
          def options(argv, options)
            Signal.trap('INT') { Kernel.abort '' }

            OptionParser.new do |option| # rubocop:disable Metrics/BlockLength
              program_name = option.program_name
              option.banner = <<~BANNER
                Usage: #{program_name} [options...] <SHEET>

                See #{program_name}(1) manual page for detailed help.

                Options:

              BANNER

              option.on('--paper PAPER', 'Paper size [default: a4]', String) do |opt|
                options.paper = opt
              end

              option.on('--variant VARIANT', 'Sheet variant', String) do |opt|
                options.variant = opt
              end

              option.on('--landscape', 'Use landscape orientation') do
                options.orientation = :landscape
              end

              option.on('-o', '--output FILE', 'Output file', String) do |opt|
                options.output = opt
              end

              option.on('--pdf', 'Generate PDF') do |_opt|
                raise NotImplementedError
              end

              option.on('-l', '--list', 'List guidesheets') do
                list
                exit
              end

              option.on_tail('-h', '--help', 'Show this message') do
                abort option.help
              end

              option.on_tail('-v', '--version', 'Show version') do
                warn VERSION
                exit
              end
            end.tap { |parser| parser.parse!(argv) } # rubocop:disable Style/MultilineBlockChain
          end
          # codebeat:enable[LOC]
          # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

          def args(parser, argv)
            if argv.empty?
              warn parser.help
              warn ''
              abort "Error: Guidesheet type required. Type #{parser.program_name} -l to list all available guidesheets."
            end

            return if argv.size <= 1

            warn parser.help
            warn ''
            abort 'Error: Too many arguments.'
          end

          def list
            warn 'Sheets:'
            warn ''
            warn Sheets.dump(prefix: "\t")
          end
        end
      end
    end
  end
end
