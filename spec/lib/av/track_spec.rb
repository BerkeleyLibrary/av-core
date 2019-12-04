require 'spec_helper'

module AV
  describe Track do
    describe :file_type do
      it 'extrapolates from path' do
        track = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp3')
        expect(track.file_type).to eq(AV::Types::FileType::MP3)

        track = Track.new(sort_order: 1, path: 'mrc/6927.mp4')
        expect(track.file_type).to eq(AV::Types::FileType::MP4)
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

    describe :to_s do
      it 'includes all relevant info' do
        track_params = {
          sort_order: 19,
          title: 'reel 20, part 1',
          path: 'C040791201_1.mp3',
          duration: AV::Types::Duration.from_string('00:40:12')
        }
        track_str = Track.new(track_params).to_s
        track_params.values.each do |v|
          expect(track_str).to include(v.to_s)
        end
      end
    end

    describe :tracks_from do
      it 'reads the tracks' do
        expected_tracks = [
          Track.new(sort_order: 0, title: 'reel 1, part 1', path: 'C040790863_1.mp3', duration: AV::Types::Duration.from_string('00:47:49')),
          Track.new(sort_order: 1, title: 'reel 2, part 1', path: 'C040790960_1.mp3', duration: AV::Types::Duration.from_string('00:23:29')),
          Track.new(sort_order: 2, title: 'reel 3, part 1', path: 'C040791061_1.mp3', duration: AV::Types::Duration.from_string('00:22:56')),
          Track.new(sort_order: 3, title: 'reel 4, part 1', path: 'C040791168_1.mp3', duration: AV::Types::Duration.from_string('00:21:46')),
          Track.new(sort_order: 4, title: 'reel 5, part 1', path: 'C040790872_1.mp3', duration: AV::Types::Duration.from_string('00:24:19')),
          Track.new(sort_order: 5, title: 'reel 6, part 1', path: 'C040790979_1.mp3', duration: AV::Types::Duration.from_string('00:24:18')),
          Track.new(sort_order: 6, title: 'reel 7, part 1', path: 'C040791070_1.mp3', duration: AV::Types::Duration.from_string('00:24:18')),
          Track.new(sort_order: 7, title: 'reel 8, part 1', path: 'C040791177_1.mp3', duration: AV::Types::Duration.from_string('00:23:23')),
          Track.new(sort_order: 8, title: 'reel 9, part 1', path: 'C040790881_1.mp3', duration: AV::Types::Duration.from_string('00:20:01')),
          Track.new(sort_order: 9, title: 'reel 10', path: 'C040790988.mp3', duration: AV::Types::Duration.from_string('00:22:38')),
          Track.new(sort_order: 10, title: 'reel 11', path: 'C040791089.mp3', duration: AV::Types::Duration.from_string('00:23:44')),
          Track.new(sort_order: 11, title: 'reel 12', path: 'C040791186.mp3', duration: AV::Types::Duration.from_string('00:22:27')),
          Track.new(sort_order: 12, title: 'reel 13, part 1', path: 'C040790890_1.mp3', duration: AV::Types::Duration.from_string('00:21:57')),
          Track.new(sort_order: 13, title: 'reel 14, part 1', path: 'C040790997_1.mp3', duration: AV::Types::Duration.from_string('00:44:28')),
          Track.new(sort_order: 14, title: 'reel 15, part 1', path: 'C040791098_1.mp3', duration: AV::Types::Duration.from_string('00:44:33')),
          Track.new(sort_order: 15, title: 'reel 16, part 1', path: 'C040790906_1.mp3', duration: AV::Types::Duration.from_string('00:44:01')),
          Track.new(sort_order: 16, title: 'reel 17, part 1', path: 'C040791007_1.mp3', duration: AV::Types::Duration.from_string('00:46:58')),
          Track.new(sort_order: 17, title: 'reel 18, part 1', path: 'C040791104_1.mp3', duration: AV::Types::Duration.from_string('00:42:49')),
          Track.new(sort_order: 18, title: 'reel 19, part 1', path: 'C040791195_1.mp3', duration: AV::Types::Duration.from_string('00:44:35')),
          Track.new(sort_order: 19, title: 'reel 20, part 1', path: 'C040791201_1.mp3', duration: AV::Types::Duration.from_string('00:40:12'))
        ]

        marc_record = AV::Marc::Millennium.marc_from_html(File.read('spec/data/b23161018.html'))
        tracks = Track.tracks_from(marc_record)
        expect(tracks).to eq(expected_tracks)
      end

      it 'handles records with no tracks' do
        marc_record = AV::Marc::Millennium.marc_from_html(File.read('spec/data/b23161018-original.html'))
        tracks = Track.tracks_from(marc_record)
        expect(tracks).to eq([])
      end
    end
  end
end
