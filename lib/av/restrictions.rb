module AV
  class Restrictions

    # TODO: remove 85642$y and 95640$z once we confirm all records have 998$r
    SUBFIELD_VALUE_SPECS = %w[998$r/#-# 856$y/#-#{^1=\4}{^2=\2} 956$z/#-#{^1=\4}{^2=\0}].freeze

    RE_CALNET_ONLY = /CalNet/i
    RE_CALNET_OR_IP = /UCB access|UCB only/i

    attr_reader :marc_record

    def initialize(marc_record)
      @marc_record = marc_record
    end

    def calnet_only?
      @calnet ||= any_field_value_matches?(RE_CALNET_ONLY)
    end

    def calnet_or_ip?
      @ucb_ip ||= any_field_value_matches?(RE_CALNET_OR_IP)
    end

    private

    def any_field_value_matches?(re)
      field_values.any? { |v| re =~ v }
    end

    def field_values
      @field_values ||= SUBFIELD_VALUE_SPECS.flat_map { |spec| MARC::Spec.find(spec, marc_record) }
    end
  end
end
