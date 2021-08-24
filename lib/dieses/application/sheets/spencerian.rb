# frozen_string_literal: true

module Dieses
  module Application
    module Sheets
      class Spencerian < Sheet
        sheet :spencerian, 'Spencerian worksheet'

        include Mixins::Scribes[:sextet].with unit: [5, 7], ratio: [3/2r, 2/1r]

        cline :slant, :fine,               angle: 52.0
        cline :connective, :fine, :dashed, angle: 30.0

        def call
          scribes
        end
      end
    end
  end
end
