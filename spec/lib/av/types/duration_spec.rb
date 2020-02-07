require 'spec_helper'

module AV
  module Types
    describe Duration do
      describe :from_string do
        it 'parses HH:MM:SS' do
          duration = Duration.from_string('12:34:56')
          expect(duration).not_to be_nil
          expect(duration.hours).to eq(12)
          expect(duration.minutes).to eq(34)
          expect(duration.seconds).to eq(56)
        end

        it 'parses HHMMSS' do
          duration = Duration.from_string('123456')
          expect(duration).not_to be_nil
          expect(duration.hours).to eq(12)
          expect(duration.minutes).to eq(34)
          expect(duration.seconds).to eq(56)
        end

        it 'parses H:MM:SS' do
          duration = Duration.from_string('2:34:56')
          expect(duration).not_to be_nil
          expect(duration.hours).to eq(2)
          expect(duration.minutes).to eq(34)
          expect(duration.seconds).to eq(56)
        end

        it 'parses HMMSS' do
          duration = Duration.from_string('23456')
          expect(duration).not_to be_nil
          expect(duration.hours).to eq(2)
          expect(duration.minutes).to eq(34)
          expect(duration.seconds).to eq(56)
        end

        it 'parses MM:SS' do
          duration = Duration.from_string('34:56')
          expect(duration).not_to be_nil
          expect(duration.hours).to eq(0)
          expect(duration.minutes).to eq(34)
          expect(duration.seconds).to eq(56)
        end

        it 'parses MMSS' do
          duration = Duration.from_string('3456')
          expect(duration).not_to be_nil
          expect(duration.hours).to eq(0)
          expect(duration.minutes).to eq(34)
          expect(duration.seconds).to eq(56)
        end

        it 'returns nil for garbage' do
          duration = Duration.from_string('Not a duration')
          expect(duration).to be_nil
        end
      end

      describe :<=> do
        it 'returns 0 for equivalent durations' do
          d1 = Duration.from_string('00:34:56')
          d2 = Duration.new(hours: 0, minutes: 34, seconds: 56)
          expect(d1 <=> d2).to eq(0)
          expect(d2 <=> d1).to eq(0)
        end

        it 'returns nil for nil' do
          d = Duration.from_string('00:34:56')
          expect(d <=> nil).to be_nil
        end

        it 'returs nil for things that are not durations' do
          d = Duration.from_string('00:34:56')
          expect(d <=> d.to_s).to be_nil
        end
      end
    end
  end
end
