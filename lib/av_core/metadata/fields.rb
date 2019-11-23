Dir.glob("#{File.expand_path('fields', __dir__)}/**/*.rb").sort.each(&method(:require))

module AVCore
  module Metadata
    module Fields
      class << self
        def fields_from(marc_record)
          Readers.all.map { |r| r.create_field(marc_record) }.compact
        end
      end
    end
  end
end
