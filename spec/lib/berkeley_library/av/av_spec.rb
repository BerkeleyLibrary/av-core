require 'spec_helper'

module BerkeleyLibrary
  describe AV do
    describe :configure do
      it 'exposes the configuration' do
        conf = AV.configure { config }
        expect(conf).to eq(AV::Config)
      end
    end
  end
end
