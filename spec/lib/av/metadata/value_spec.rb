require 'spec_helper'

module AV
  class Metadata
    describe Value do
      describe :<=> do
        it 'can compare text with links' do
          v1 = Value.new(tag: '956', label: 'test', entries: ['test'], order: 1)
          v2 = Value.new(tag: '956', label: 'test', entries: [Link.new(body: 'test', url: 'http://example.org')], order: 1)
          actual = v1 <=> v2
          expect(actual).not_to eq(0)
          expect(actual).to eq(v1.entries.to_s <=> v2.entries.to_s)
        end

        it 'returns nil for nil' do
          v = Value.new(tag: '956', label: 'test', entries: ['test'], order: 1)
          expect(v <=> nil).to be_nil
        end

        it 'returns nil for things that are not Values' do
          v = Value.new(tag: '956', label: 'test', entries: ['test'], order: 1)
          expect(v <=> v.to_s).to be_nil
        end
      end
    end
  end
end
