require 'spec_helper'
require 'avplayer/core'

module AvPlayer
  module Core
    describe Record do
      describe :new do
        it 'sorts the tracks' do
          t1 = Track.new(sort_order: 1, title: 'Part 1', path: 'frost-read1.mp3')
          t2 = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp3')
          record = Record.new(bib_number: '11082434', tracks: [t2, t1])
          tracks = record.tracks
          expect(tracks[0]).to eq(t1)
          expect(tracks[1]).to eq(t2)
        end
      end
    end
  end
end
