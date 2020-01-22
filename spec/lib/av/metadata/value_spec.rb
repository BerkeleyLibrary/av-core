require 'spec_helper'

module AV
  class Metadata
    describe Value do
      describe :<=> do
        it 'falls back to to_s' do
          v1 = TextValue.new(tag: '956', label: 'test', lines: ['test'], order: 1)
          v2 = LinkValue.new(tag: '956', label: 'test', links: [Link.new(body: 'test', url: 'http://example.org')], order: 1)
          actual = v1 <=> v2
          expect(actual).not_to eq(0)
          expect(actual).to eq(v1.to_s <=> v2.to_s)
        end
      end
    end
  end
end
