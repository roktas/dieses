# frozen_string_literal: true

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

      OPTIONS    = {
        destdir: 'sheets'
      }.freeze

      module_function

      def call(*argv, **options) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        options = OpenStruct.new(OPTIONS.merge(options))
        args options(argv, options), argv

        index_file = argv.first

        if options.index
          abort("Index file exists: #{index_file}") if options.no_clobber && File.exist?(index_file)

          return write_index(index_file, Application.combinations)
        end

        abort("Index file not found: #{index_file}") unless File.exist?(index_file)

        abort("Destination directory exists: #{options.destdir}") if Dir.exist?(options.destdir) && options.no_clobber

        write_index(index_file, Application.batch(read_index(index_file), prefix: options.destdir))
      rescue OptionParser::InvalidOption, Diesis::Error => e
        abort(e.message)
      end

      def options(argv, options) # rubocop:disable Metrics/MethodLength
        Signal.trap('INT') { Kernel.abort '' }

        OptionParser.new do |option|
          program_name = option.program_name
          option.banner = <<~BANNER
            Usage: #{program_name} [options...] <INDEXFILE>

            See #{program_name}(1) manual page for detailed help.

            Options:

          BANNER

          option.on('--index', 'Create index for all variants without producing sheets') do |opt|
            options.index = opt
          end

          option.on('--destdir DIR', 'Destination directory') do |opt|
            options.destdir = opt
          end

          option.on('--no-clobber', 'Do not overwrite an existing file or directory') do
            options.no_clobber = true
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

      def read_index(index_file)
        JSON.load_file(index_file).map! { |h| h.transform_keys!(&:to_sym) }
      end

      private_class_method :write_index
    end
  end
end
