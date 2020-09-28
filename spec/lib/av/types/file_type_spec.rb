require 'spec_helper'

module AV
  module Types
    describe FileType do
      describe :mime_type do
        it 'is correct' do
          expected = {
            FileType::MP3 => 'application/x-mpegURL',
            FileType::MP4 => 'video/mp4',
            FileType::MOV => 'video/quicktime',
            FileType::UNKNOWN => 'application/octet-stream'
          }
          expected.each do |t, mt_expected|
            expect(t.mime_type).to eq(mt_expected)
          end
        end
      end

      describe :player_tag do
        it 'is correct' do
          expected = {
            FileType::MP3 => 'audio',
            FileType::MP4 => 'video',
            FileType::MOV => 'video',
            FileType::UNKNOWN => 'object'
          }
          expected.each do |t, pt_expected|
            expect(t.player_tag).to eq(pt_expected)
          end
        end
      end

      describe :label do
        it 'is correct' do
          expected = {
            FileType::MP3 => 'Audio',
            FileType::MP4 => 'Video',
            FileType::MOV => 'Video',
            FileType::UNKNOWN => 'Unknown'
          }
          expected.each do |t, pt_expected|
            expect(t.label).to eq(pt_expected)
          end
        end
      end

      describe :to_s do
        it 'returns the value' do
          FileType.each do |t|
            expect(t.to_s).to eq(t.value.to_s)
          end
        end
      end

      describe :for_path do
        it 'identifies an MP3' do
          expect(FileType.for_path('foo.mp3')).to eq(AV::Types::FileType::MP3)
        end

        it 'identifies an MP4' do
          expect(FileType.for_path('foo.mp4')).to eq(AV::Types::FileType::MP4)
        end

        it 'identifies an MOV' do
          expect(FileType.for_path('foo.mov')).to eq(AV::Types::FileType::MOV)
        end

        it 'returns UNKNOWN for nil' do
          # noinspection RubyYardParamTypeMatch
          expect(FileType.for_path(nil)).to eq(AV::Types::FileType::UNKNOWN)
        end

        it 'returns UNKNOWN for unknown types' do
          expect(FileType.for_path('foo.txt')).to eq(AV::Types::FileType::UNKNOWN)
        end
      end
    end
  end
end
