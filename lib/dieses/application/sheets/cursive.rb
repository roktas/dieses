# frozen_string_literal: true

module Dieses
  module Application
    module Sheets
      class Cursive < Sheet
        sheet :cursive, 'Cursive worksheet'

        include Mixins::Scribes[:quartet].with unit: [5, 7, 10]

        cline :slant, :fine, angle: 60.0

        def call
          scribes
        end
      end
    end
  end
end
