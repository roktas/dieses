# frozen_string_literal: true

module Dieses
  module Application
    module Sheets
      class Italics < Sheet
        sheet :italics, 'Italics worksheet'

        include Mixins::Scribes[:quartet].with unit: [5, 7, 10]

        cline :slant, :fine, angle: 81.0

        def call
          scribes
        end
      end
    end
  end
end
