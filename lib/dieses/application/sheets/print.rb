# frozen_string_literal: true

module Dieses
  module Application
    module Sheets
      class Print < Sheet
        sheet :print, 'Print style worksheet'

        include Mixins::Scribes[:quartet].with unit: [5, 7, 10]

        vline %i[vline]

        def call
          scribes
        end
      end
    end
  end
end
