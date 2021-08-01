# frozen_string_literal: true

require 'fileutils'
require 'optparse'
require 'ostruct'

require 'diesis'

module Diesis
  module CLI
    Error = Class.new Error

    module_function

    def call(*argv, **options)
      options = OpenStruct.new(options)
      args options(argv, options), argv

      sheet = argv.first

      return puts(out = Application.(sheet, **options.to_h)) unless options[:output]

      File.write(options[:output], out)
    rescue OptionParser::InvalidOption, Diesis::Error => e
      abort(e.message)
    end

    def options(argv, options) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
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

        option.on('--pdf', 'Generate PDF') do |opt|
          options.pdf = opt
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

    private_class_method :options

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
      warn Application::Sheets.dump(prefix: "\t")
    end

    private_class_method :args

    module Batch
      require 'json'

      INDEX_FILE = 'index.json'

      module_function

      def call(*argv, **options)
        options = OpenStruct.new(options)
        args options(argv, options), argv

        # puts Application.combinations.map(&:to_h); exit

        destdir = argv.first

        FileUtils.rm_rf(destdir)

        combinations = Application.combinations.select do |combination|
          combination.call(destdir)
        end

        write_index(File.join(destdir, INDEX_FILE), combinations)
      rescue OptionParser::InvalidOption, Diesis::Error => e
        abort(e.message)
      end

      def options(argv, options) # rubocop:disable Metrics/MethodLength
        Signal.trap('INT') { Kernel.abort '' }

        OptionParser.new do |option|
          program_name = option.program_name
          option.banner = <<~BANNER
            Usage: #{program_name} [options...] <DESTDIR>

            See #{program_name}(1) manual page for detailed help.

            Options:

          BANNER

          option.on('--force', 'Force to remove an existing base directory') do |opt|
            options.force = opt
          end

          option.on('--pdf', 'Generate PDF') do |opt|
            options.pdf = opt
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

      private_class_method :options

      def args(parser, argv)
        if argv.empty?
          warn parser.help
          warn ''
          abort 'Error: Destination directory required.'
        end

        return if argv.size <= 1

        warn parser.help
        warn ''
        abort 'Error: Too many arguments.'
      end

      private_class_method :args

      def write_index(index_file, combinations)
        return if combinations.empty?

        combinations = combinations.map(&:to_h).sort_by do |hash|
          hash.values_at(*%i[sheet variant paper orientation])
        end

        File.write(index_file, JSON.pretty_generate(combinations))
      end

      private_class_method :write_index
    end
  end
end
