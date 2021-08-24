# frozen_string_literal: true

module Dieses
  module Application
    module Sheets
      class Copperplate < Sheet
        sheet :copperplate, 'Copperplate worksheet'

        include Mixins::Scribes[:sextet].with unit: [5, 7], ratio: [3/2r, 2/1r]

        cline :slant, :fine,               angle: 55.0
        cline :connective, :fine, :dashed, angle: 50.0

        def call
          scribes
        end
      end
    end
  end
end
