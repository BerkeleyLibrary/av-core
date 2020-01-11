require 'spec_helper'

module AV
  module Legacy
    describe Collection do
      describe :COLLECTION_TO_WOWZA_COLLECTION do
        it 'maps each expected collection to a Wowza collection' do
          collections = %w[
            banclectures
            christmas
            cityarts
            irene mrc
            music
            pacifica
            rohoaudio
            ucbaudio
          ]
          collections.each do |db_coll|
            wowza_coll = Collection::COLLECTION_TO_WOWZA_COLLECTION[db_coll]
            expect(wowza_coll).not_to be_nil
          end
        end
      end
    end
  end
end
