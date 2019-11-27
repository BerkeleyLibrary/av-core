require 'spec_helper'
require 'av/marc/millennium'

module AV
  module Marc
    describe Millennium do
      it 'extracts MARC' do
        marc_record = Millennium.marc_from_html(File.read('spec/data/b22139658.html'))

        title = marc_record['245']
        expect(title['a']).to eq('Communists on campus')
        expect(title['h']).to eq('[electronic resource] /')
        expect(title['c']).to eq('presented by the National Education Program, Searcy, Arkansas ; writer and producer, Sidney O. Fields.')

        expected_summary = <<~TEXT
          An American propaganda documentary created "to inform and
          impress on American citizens the true nature and the true
          magnitude of those forces that are working within our
          nation for its overthrow...and the destruction of our
          educational system." Film covers the July 1969 California
          Revolutionary Conference and other demonstrations, warning
          against the activities of Students for a Democratic
          Society, the Black Panthers, student protestors and
          Vietnam War demonstrators as they promote a "socialist/
          communist overthrow of the U.S. government," taking as
          their mentor Chairman Mao Tse-Tung.
        TEXT
        expected_summary = expected_summary.gsub("\n", ' ').strip

        summary = marc_record['520']
        expect(summary['a']).to eq(expected_summary)

        personal_names = marc_record.fields('700')
        expect(personal_names.size).to eq(27)
      end
    end
  end
end
