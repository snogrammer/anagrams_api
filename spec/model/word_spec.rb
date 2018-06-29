# frozen_string_literal: true

require 'rails_helper'

describe Word, models: true do
  it { is_expected.to be_mongoid_document }
  it { is_expected.to be_stored_in(collection: 'words') }
  it { is_expected.to have_field(:name).of_type(String) }
  it { is_expected.to have_field(:characters).of_type(String).with_default_value_of(nil) }
  it { is_expected.to have_field(:proper_noun).of_type(Mongoid::Boolean).with_default_value_of(false) }
  it { is_expected.to have_timestamps }
  it { is_expected.to have_field(:deleted_at).of_type(Time).with_default_value_of(nil) }

  context 'validations' do
    describe 'name' do
      it { is_expected.to validate_presence_of(:name).with_message('is required') }
      it do
        is_expected.to validate_length_of(:name)
          .within(1..255)
          .with_message('must have more than 1 and less than 255 characters')
      end
      it { is_expected.to validate_uniqueness_of(:name).with_message('already exists in corpus') }
    end

    describe 'characters' do
      it { is_expected.to validate_presence_of(:characters).with_message('is required') }
    end
  end

  describe '#sort_characters' do
    it 'sorts characters in ascending order' do
      word = FactoryBot.build(:word, name: 'Ibotta')
      expect(word.sort_characters).to eq('abiott')
    end

    it 'removes non-alphabet characters' do
      word = FactoryBot.build(:word, name: ' SU,PER- he&ro! ')
      expect(word.sort_characters).to eq('eehoprrsu')
    end
  end

  describe '#set_proper_noun' do
    it 'returns true when first character is uppercase' do
      word = FactoryBot.build(:word, name: 'Ibotta')
      expect(word.send(:set_proper_noun)).to be_truthy
    end

    it 'returns true when all characters is uppercase' do
      word = FactoryBot.build(:word, name: 'IBOTTA')
      expect(word.send(:set_proper_noun)).to be_truthy
    end

    it 'returns false when first character is lowercase' do
      word = FactoryBot.build(:word, name: 'ibotta')
      expect(word.send(:set_proper_noun)).to be_falsey
    end

    it 'returns false when first character is lowercase' do
      word = FactoryBot.build(:word, name: 'iBOTTA')
      expect(word.send(:set_proper_noun)).to be_falsey
    end
  end

  describe '#save' do
    let(:word) { FactoryBot.build(:word, name: 'read') }

    it 'persists word' do
      expect(word[:name]).to eq('read')
      expect(word[:proper_noun]).to eq(false)
      expect(word[:characters]).to eq(nil)

      expect(word.valid?).to be_truthy
      expect(word[:name]).to eq('read')
      expect(word[:proper_noun]).to eq(false)
      expect(word[:characters]).to eq('ader')
      expect(word.save!).to be_truthy
    end
  end
end
