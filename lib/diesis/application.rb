# frozen_string_literal: true

require_relative 'application/common'
require_relative 'application/paper'
require_relative 'application/canvas'
require_relative 'application/pen'
require_relative 'application/mixins'
require_relative 'application/sheet'
require_relative 'application/sheets'

module Diesis
  module Application
    module_function

    def call(sheet, variant: Undefined, paper: :a4, orientation: :portrait, **render_args)
      sheet(sheet, variant: variant, paper: paper, orientation: orientation).produce(**render_args)
    end

    def sheet(sheet, variant: Undefined, paper: :a4, orientation: :portrait)
      Sheets.sheet(sheet.to_sym).new(Paper.public_send(paper.to_sym).orient(orientation.to_sym), variant: variant)
    end

    Combination = Struct.new :sheet, :variant, :paper, :orientation, keyword_init: true do
      def to_s
        "#{sheet}-#{variant}@#{paper}-#{orientation}"
      end

      def to_h
        super.merge file: relfile
      end

      def relfile
        File.join(reldir, "#{self}.svg")
      end

      def file(basedir)
        File.join(File.expand_path(basedir), relfile)
      end

      def call(basedir)
        file    = file(basedir)
        content = Application.(sheet, variant: variant, paper: paper, orientation: orientation)

        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, content)

        true
      rescue NotImplementedError, NonApplicableError
        false
      end

      private

      def reldir
        File.join(paper, orientation, sheet)
      end
    end

    private_constant :Combination

    PAPERS       = %i[a4 a5].freeze
    ORIENTATIONS = Geometry::Rect::Orientation.values

    def combinations(papers: PAPERS, orientations: ORIENTATIONS) # rubocop:disable Metrics/MethodLength
      [].tap do |combinations|
        papers.each do |paper|
          Sheets.available.each do |sheet, spec|
            spec.variants.each do |variant|
              orientations.each do |orientation|
                combinations << Combination.new(sheet:       sheet.to_s,
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
