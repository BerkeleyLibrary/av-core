require 'spec_helper'

require 'av/player'

module AV
  describe Player do
    describe :link_to do
      it 'generates a link for a single file' do
        uri = Player.link_to(
          collection: 'Pacifica',
          paths: 'PRA_NHPRC1_AZ1084_00_000_00.mp3',
          bib_number: 'b23305522'
        )
        expect(uri).to be_a(URI)

        host = Player.avplayer_host
        expected = "https://#{host}/Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3/show?record_id=millennium%3Ab23305522"
        expect(uri.to_s).to eq(expected)
      end

      it 'generates a link for multiple files' do
        uri = Player.link_to(
          collection: 'City',
          paths: %w[CA01476a.mp3 CA01476b.mp3],
          bib_number: 'b18538031'
        )
        expect(uri).to be_a(URI)

        host = Player.avplayer_host
        expected = "https://#{host}/City/CA01476a.mp3;CA01476b.mp3/show?record_id=millennium%3Ab18538031"
        expect(uri.to_s).to eq(expected)
      end
    end
  end
end
