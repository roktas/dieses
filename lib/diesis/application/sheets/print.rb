# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Print < Sheet
        sheet :print, 'Print style worksheet'

        include Mixins::Scribe[:quartet].with unit: [5, 7, 10]

        vline :vline, style: Style.(stroke: 'blue', 'stroke-width': '0.05')

        def call
          scribes
        end
      end
    end
  end
end
