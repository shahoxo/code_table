require 'spec_helper'

describe CodeTable::Loader do
  before { CodeTable::Config.load_path = 'spec/fixtures' }

  describe '.load' do
    it 'should load classes' do
      expect { described_class.load }.to change { defined? Weapon }.from(nil).to('constant')
    end

    it 'should define type methods at loaded class' do
      Weapon.spear.should eq 0
      Weapon.sword.should eq 2
    end
  end
end
