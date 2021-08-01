# frozen_string_literal: true

require 'optparse'
require 'ostruct'

module Diesis
  module Application
    module CLI
      module Multi
        OPTIONS = EMPTY_HASH

        def self.call(*argv, **options)
          options = OpenStruct.new(OPTIONS.merge(options))
          args options(argv, options), argv

          index_file = argv.first

          return build_index(index_file, options) if options.index

          batch_run(index_file, options)
        rescue OptionParser::InvalidOption, Diesis::Error => e
          abort(e.message)
        end

        class << self
          private

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

              option.on('--pdf', 'Generate PDF') do |_opt|
                raise NotImplementedError
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

          def args(parser, argv)
            if argv.empty?
              warn parser.help
              warn ''
              abort 'Error: Index file required.'
            end

            return if argv.size <= 1

            warn parser.help
            warn ''
            abort 'Error: Too many arguments.'
          end

          def build_index(index_file, options)
            abort("Index file exists: #{index_file}") if options.no_clobber && File.exist?(index_file)

            productions, unprocessed = Batch.index Batch.from_json_file(index_file)

            warn "Warning: There are #{unprocessed.size} new sheets which should be processed" unless unprocessed.empty?

            Batch.to_json_file(index_file, productions)
          end

          def batch_run(index_file, options)
            abort("Index file not found: #{index_file}") unless File.exist?(index_file)

            destdir = options.destdir || File.join(File.dirname(index_file))
            abort("Destination directory exists: #{destdir}") if Dir.exist?(destdir) && options.no_clobber

            FileUtils.rm_rf(Dir[File.join(destdir, '*')].select { |file| File.directory?(file) })
            Batch.from_json_file(index_file).each { |production| production.run(destdir) }
          end
        end
      end
    end
  end
end
