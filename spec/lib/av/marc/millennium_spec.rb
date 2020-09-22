require 'spec_helper'

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

        link = marc_record['856']
        expect(link['z']).to eq('UC Berkeley online videos. Freely available.')
        expect(link['u']).to eq('https://avplayer.lib.berkeley.edu/b22139658')
      end

      it 'handles long 856 links' do
        marc_record = Millennium.marc_from_html(File.read('spec/data/b23161018-unmigrated.html'))
        link = marc_record['856']
        expect(link['u']).to eq('http://servlet1.lib.berkeley.edu:8080/audio/stream.play.logic?coll=music&group=b23161018')
      end

      # TODO: sort this out in a way that doesn't bork filenames with spaces
      xit 'handles wrapped 998 filenames' do
        marc_record = Millennium.marc_from_html(File.read('spec/data/b25742488.html'))
        df_998 = marc_record['998']
        expect(df_998['g']).to eq('Monumental_Crossroads_DSL_Hosted_Streaming_92Gf726T7a.mov')
      end
    end
  end
end
