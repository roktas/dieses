# frozen_string_literal: true

require_relative '../test_helper'

module Dieses
  module Application
    class IntegrationTest < Minitest::Test
      PREFIX_DIR = 'docs/sheets'

      def test_default_productions
        Batch.defaults.each do |production|
          file = File.expand_path(production.file, PREFIX_DIR)

          expected = File.read(file)
          actual = production.call

          assert_equal expected, actual, "Production #{production} doesn't match with the content of file: #{file}"
        end
      end

      def test_all_processed
        _, unprocessed = Batch.index Batch.from_json_file(File.join(PREFIX_DIR, 'index.json'))
        assert unprocessed.empty?
      end
    end
  end
end
