require 'spec_helper'

describe CodeTable::Model do
  class Color
    include CodeTable::Model

    @kinds = { red: 0, blue: 1, green: 2 }
  end

  describe "test Color that include CodeTable::Model and kinds: #{Color.kinds}" do

    describe '.fetch_by_code' do
      context 'with red code 0' do
        subject { Color.fetch_by_code(0) }
        it { should eq :red }
      end
    end

    describe '.fetch_by_type' do
      context 'with blue type' do
        subject { Color.fetch_by_type(:blue) }
        it { should eq 1 }
      end
    end

    describe '.build' do
      context 'with only code 2' do
        subject { Color.build(code: 2) }
        it 'should green instance' do
          should be_kind_of Color
          subject.code.should eq 2
          subject.type.should eq :green
        end
      end

      context 'with only type :red' do
        subject { Color.build(type: :red) }
        it 'should red instance' do
          should be_kind_of Color
          subject.code.should eq 0
          subject.type.should eq :red
        end
      end

      context 'with code and type :blue' do
        subject { Color.build(code: 1, type: :blue) }
        it 'should blue instance' do
          should be_kind_of Color
          subject.code.should eq 1
          subject.type.should eq :blue
        end
      end

      context 'with nil' do
        it { expect { Color.build }.to raise_error CodeTable::Model::InvalidKindError }
      end

      context 'with unknown code' do
        it { expect { Color.build(code: 5) }.to raise_error CodeTable::Model::InvalidKindError }
      end

      context 'with unknown type' do
        it { expect { Color.build(type: :black) }.to raise_error CodeTable::Model::InvalidKindError }
      end

      context 'with invalid combination' do
        it { expect { Color.build(code: 1, type: :red) }.to raise_error CodeTable::Model::InvalidKindError }
      end
    end

    describe '#==' do
      let(:red_color) { Color.build(type: :red) }

      context 'with same type' do
        subject { red_color == Color.build(code: 0) }
        it { should be true }
      end

      context 'with different type' do
        subject { red_color == Color.build(type: :green) }
        it { should be false }
      end
    end
  end

end