require 'spec_helper'

describe AV do
  describe :configure do
    it 'exposes the configuration' do
      conf = AV.configure { config }
      expect(conf).to eq(AV::Config)
    end
  end
end
