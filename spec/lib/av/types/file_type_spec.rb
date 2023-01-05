require 'spec_helper'

module AV
  module Types
    describe FileType do
      describe :mime_type do
        it 'is correct' do
          expected = {
            FileType::MP3 => 'application/x-mpegURL',
            FileType::MP4 => 'video/mp4',
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
            FileType::UNKNOWN => 'object'
          }
          expected.each do |t, pt_expected|
            expect(t.player_tag).to eq(pt_expected)
          end
        end
      end

      describe :prefix do
        it 'is correct' do
          expected = {
            FileType::MP3 => 'mp3',
            FileType::MP4 => 'mp4',
            FileType::UNKNOWN => 'unknown'
          }
          expected.each do |t, prefix_expected|
            expect(t.prefix).to eq(prefix_expected)
          end
        end
      end

      describe :label do
        it 'is correct' do
          expected = {
            FileType::MP3 => 'Audio',
            FileType::MP4 => 'Video',
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
          %w[.mp4 .f4v .mov .m4a .m4v .mp4a .mp4v .3gp .3g2].each do |ext|
            expect(FileType.for_path("foo#{ext}")).to eq(AV::Types::FileType::MP4)
          end
        end

        it 'returns UNKNOWN for nil' do
          # noinspection RubyYardParamTypeMatch
          expect(FileType.for_path(nil)).to eq(AV::Types::FileType::UNKNOWN)
        end

        it 'returns UNKNOWN for unknown types' do
          expect(FileType.for_path('foo.txt')).to eq(AV::Types::FileType::UNKNOWN)
        end
      end

      describe :new do
        it "doesn't allow duplicate extensions" do
          expect { FileType.send(:new, :QT, 'video', 'video/qt', extensions: ['.mov']) }
            .to raise_error(ArgumentError, /.mov/)
          expect(defined? FileType::QT).to be_nil
        end
      end
    end
  end
end
