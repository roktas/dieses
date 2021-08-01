# frozen_string_literal: true

require 'fileutils'
require 'json'

module Diesis
  module Application
    module Batch
      Production = Struct.new :sheet, :variant, :desc, :paper, :orientation, :file, :produce, keyword_init: true do
        def self.call(**kwargs)
          new(**kwargs.slice(*members)).tap do |production|
            production.file = production.relfile unless production.file
          end
        end

        def to_s
          suffix = orientation.to_s == 'landscape' ? 'l' : ''
          "#{sheet}-#{variant}@#{paper}#{suffix}"
        end

        def key
          to_s.to_sym
        end

        def relfile
          File.join(reldir, "#{self}.svg")
        end

        def call
          Application.produce(sheet, variant: variant, paper: paper, orientation: orientation)
        end

        def run(basedir)
          unless produce
            warn "Undefined production request; skipping: #{self}" if produce.nil?

            return
          end

          outfile = File.join(File.expand_path(basedir), file)
          content = call

          FileUtils.mkdir_p(File.dirname(outfile))
          File.write(outfile, content)
        end

        private

        def reldir
          File.join(sheet, paper)
        end
      end

      private_constant :Production

      module_function

      PAPERS       = %i[a4 a5].freeze
      ORIENTATIONS = Orientation.values

      # rubocop:disable Metrics/MethodLength
      # codebeat:disable[BLOCK_NESTING]
      def all(papers: PAPERS, orientations: ORIENTATIONS)
        Set.new.tap do |productions|
          papers.each do |paper|
            Sheets.available.each do |sheet, proto|
              proto.variants.each do |variant|
                orientations.each do |orientation|
                  productions << Production.(sheet:       sheet.to_s,
                                             variant:     variant.to_s,
                                             desc:        variant.desc,
                                             paper:       paper.to_s,
                                             orientation: orientation.to_s)
                end
              end
            end
          end
        end
      end
      # codebeat:enable[BLOCK_NESTING]

      def defaults
        Set.new(
          Sheets.defaults.map do |sheet, variant|
            Production.(sheet:       sheet.to_s,
                        variant:     variant.to_s,
                        desc:        variant.desc,
                        paper:       Paper.default.to_s,
                        orientation: Orientation.default.to_s)
          end
        )
      end

      def index(productions)
        previous = Support.hashify_by productions, :key
        current  = Support.hashify_by Batch.all, :key

        unprocessed = []
        current.each do |name, production|
          unless previous.key?(name)
            unprocessed << production

            next
          end

          production.produce = previous[name].produce
        end

        [current.values, unprocessed]
      end
      # rubocop:enable Metrics/MethodLength

      def from_json_file(file)
        JSON.load_file(file).map do |hash|
          hash.transform_keys!(&:to_sym)
          Production.(**hash.slice(*Production.members))
        end
      end

      def to_json_file(file, productions)
        content = JSON.pretty_generate(productions.map(&:to_h)).chomp

        File.write(file, "#{content}\n")
      end
    end
  end
end
