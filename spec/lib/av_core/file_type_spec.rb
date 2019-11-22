require 'spec_helper'
require 'av_core'

module AVCore
  describe FileType do
    describe :mime_type do
      it 'is correct' do
        expected = {
          FileType::MP3 => 'application/x-mpegURL',
          FileType::MP4 => 'video/mp4'
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
          FileType::MP4 => 'video'
        }
        expected.each do |t, pt_expected|
          expect(t.player_tag).to eq(pt_expected)
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
        expect(FileType.for_path('foo.mp3')).to eq(FileType::MP3)
      end

      it 'identifies an MP4' do
        expect(FileType.for_path('foo.mp4')).to eq(FileType::MP4)
      end

      it 'rejects nil' do
        expect { FileType.for_path(nil) }.to raise_error(ArgumentError)
      end

      it 'rejects unknown types' do
        expect { FileType.for_path('foo.txt') }.to raise_error(ArgumentError)
      end
    end
  end
end
