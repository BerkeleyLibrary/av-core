require 'spec_helper'
require 'avplayer/core'

module AvPlayer
  module Core
    describe Track do
      describe :file_type do
        it 'extrapolates from path' do
          track = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp3')
          expect(track.file_type).to eq(FileType::MP3)

          track = Track.new(sort_order: 1, path: 'mrc/6927.mp4')
          expect(track.file_type).to eq(FileType::MP4)
        end
      end

      describe :<=> do
        # rubocop:disable Lint/UselessComparison
        it 'treats object as equal to itself' do
          track = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp3')
          expect(track == track).to eq(true)
        end
        # rubocop:enable Lint/UselessComparison

        it 'treats object as equal to identical object' do
          t1 = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp3')
          t2 = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp3')
          expect(t1 == t2).to eq(true)
        end

        it 'sorts by sort order' do
          t1 = Track.new(sort_order: 3, title: 'Part 2', path: 'frost-read2.mp3')
          t2 = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp3')
          expect(t1 > t2).to eq(true)
          expect(t2 < t1).to eq(true)
        end

        it 'sorts by title' do
          t1 = Track.new(sort_order: 2, title: 'Part 3', path: 'frost-read2.mp3')
          t2 = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp3')
          expect(t1 > t2).to eq(true)
          expect(t2 < t1).to eq(true)
        end

        it 'sorts by path' do
          t1 = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp4')
          t2 = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp3')
          expect(t1 > t2).to eq(true)
          expect(t2 < t1).to eq(true)
        end
      end
    end
  end
end
