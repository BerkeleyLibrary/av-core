require 'spec_helper'

require 'marc'
require 'av_core/metadata'

module AVCore
  module Metadata
    module Fields
      describe Reader do
        attr_reader :marc_record

        before(:all) do
          @marc_record = MARC::XMLReader.new('spec/data/record-21178.xml').first
        end

        describe :<=> do
          it 'treats fields that differ only in subfield order as different' do
            args1 = { order: 4, tag: '711', label: 'Meeting Name', subfields_separator: ', ', subfield_order: %i[a n d c] }
            args2 = args1.merge(subfield_order: %i[c n d a])
            ff1 = Reader.new(args1)
            ff2 = Reader.new(args2)
            expect(ff1 < ff2).to be_truthy
            expect(ff2 > ff1).to be_truthy
          end
        end

        describe :to_s do
          it 'includes all pertinent info' do
            ff = Reader.new(order: 4, tag: '711', label: 'Meeting Name', subfields_separator: ', ', subfield_order: %i[c n d a])
            ffs = ff.to_s
            ['4', '711', 'Meeting Name'].each { |v| expect(ffs).to include(v) }
          end
        end

        describe 'Readers::TRACKS' do
          it 'extracts the tracks' do
            marc_html = File.read('spec/data/b23161018.html')
            marc_record = AVCore::Metadata::MillenniumMARCExtractor.new(marc_html).extract_marc_record
            field = Readers::TRACKS.create_field(marc_record)
            expect(field).to be_a(TrackField)

            expected = [
              { duration: '00:47:49', title: 'reel 1, part 1', path: 'C040790863_1.mp3' },
              { duration: '00:23:29', title: 'reel 2, part 1', path: 'C040790960_1.mp3' },
              { duration: '00:22:56', title: 'reel 3, part 1', path: 'C040791061_1.mp3' },
              { duration: '00:21:46', title: 'reel 4, part 1', path: 'C040791168_1.mp3' },
              { duration: '00:24:19', title: 'reel 5, part 1', path: 'C040790872_1.mp3' },
              { duration: '00:24:18', title: 'reel 6, part 1', path: 'C040790979_1.mp3' },
              { duration: '00:24:18', title: 'reel 7, part 1', path: 'C040791070_1.mp3' },
              { duration: '00:23:23', title: 'reel 8, part 1', path: 'C040791177_1.mp3' },
              { duration: '00:20:01', title: 'reel 9, part 1', path: 'C040790881_1.mp3' },
              { duration: '00:22:38', title: 'reel 10', path: 'C040790988.mp3' },
              { duration: '00:23:44', title: 'reel 11', path: 'C040791089.mp3' },
              { duration: '00:22:27', title: 'reel 12', path: 'C040791186.mp3' },
              { duration: '00:21:57', title: 'reel 13, part 1', path: 'C040790890_1.mp3' },
              { duration: '00:44:28', title: 'reel 14, part 1', path: 'C040790997_1.mp3' },
              { duration: '00:44:33', title: 'reel 15, part 1', path: 'C040791098_1.mp3' },
              { duration: '00:44:01', title: 'reel 16, part 1', path: 'C040790906_1.mp3' },
              { duration: '00:46:58', title: 'reel 17, part 1', path: 'C040791007_1.mp3' },
              { duration: '00:42:49', title: 'reel 18, part 1', path: 'C040791104_1.mp3' },
              { duration: '00:44:35', title: 'reel 19, part 1', path: 'C040791195_1.mp3' },
              { duration: '00:40:12', title: 'reel 20, part 1', path: 'C040791201_1.mp3' }
            ]

            aggregate_failures 'tracks' do
              field.tracks.each_with_index do |track, i|
                expect(track.duration.to_s).to eq(expected[i][:duration])
                expect(track.title).to eq(expected[i][:title])
                expect(track.path).to eq(expected[i][:path])
              end
            end
          end

          it 'accepts a record with only path info' do
            marc_html = File.read('spec/data/b22139658.html')
            marc_record = AVCore::Metadata::MillenniumMARCExtractor.new(marc_html).extract_marc_record
            field = Readers::TRACKS.create_field(marc_record)
            expect(field).to be_a(TrackField)

            tracks = field.tracks
            expect(tracks.size).to eq(1)

            track = tracks[0]
            expect(track.duration).to be_nil
            expect(track.title).to be_nil
            expect(track.path).to eq('mrc/6927.mp4')
          end
        end
      end
    end
  end
end
