# frozen_string_literal: true

require_relative 'application/common'
require_relative 'application/paper'
require_relative 'application/canvas'
require_relative 'application/pen'
require_relative 'application/mixins'
require_relative 'application/sheet'
require_relative 'application/sheets'
require_relative 'application/batch'

module Dieses
  module Application
    module_function

    def produce(sheet, variant: Undefined, paper: Paper.default, orientation: Orientation.default, **render_args)
      sheet(sheet, variant: variant, paper: paper, orientation: orientation).produce(**render_args)
    end

    def sheet(sheet, variant: Undefined, paper: Paper.default, orientation: Orientation.default)
      Sheets.sheet(sheet.to_sym).new(Paper.public_send(paper.to_sym).orient(orientation.to_sym), variant: variant)
    end
  end
end
