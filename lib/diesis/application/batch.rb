# frozen_string_literal: true

require 'fileutils'

module Diesis
  module Application
    class Batch
      Combination = Struct.new :sheet, :variant, :paper, :orientation, :file, :produce, keyword_init: true do
        def self.call(**kwargs)
          new(**kwargs.slice(*members)).tap do |combination|
            combination.file = combination.relfile unless combination.file
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

        def run(basedir)
          unless produce
            warn "State not identified skipping: #{self}" if produce.nil?

            return
          end

          outfile = File.join(File.expand_path(basedir), file)
          content = Application.(sheet, variant: variant, paper: paper, orientation: orientation)

          FileUtils.mkdir_p(File.dirname(outfile))
          File.write(outfile, content)
        end

        private

        def reldir
          File.join(sheet, paper)
        end
      end

      private_constant :Combination

      def self.run(index, prefix)
        new(index).run(prefix)
      end

      def initialize(index)
        @lookup = {}

        index.map { |h| Combination.(**h) }.each { |combination| @lookup[combination.key] = combination }
      end

      def run(prefix)
        new_lookup = {}
        combinations.each { |combination| new_lookup[combination.key] = combination }
        new_lookup.merge! lookup

        FileUtils.rm_rf prefix

        new_lookup.each_value { |combination| combination.run(prefix) }
        new_lookup.values
      end

      private

      attr_reader :lookup

      PAPERS       = %i[a4 a5].freeze
      ORIENTATIONS = Geometry::Rect::Orientation.values

      def combinations(papers: PAPERS, orientations: ORIENTATIONS) # rubocop:disable Metrics/MethodLength
        Set.new.tap do |combinations|
          papers.each do |paper|
            Sheets.available.each do |sheet, spec|
              spec.variants.each do |variant|
                orientations.each do |orientation|
                  combinations << Combination.(sheet:       sheet.to_s,
                                               variant:     variant.to_s,
                                               paper:       paper.to_s,
                                               orientation: orientation.to_s).freeze
                end
              end
            end
          end
        end
      end
    end
  end
end
