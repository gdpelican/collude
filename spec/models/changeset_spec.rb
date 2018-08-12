require './plugins/collude/spec/spec_helper'

describe ::Changeset do
  let(:set1) { build_changeset(0, 6,  "hello!".split('')) }
  let(:set2) { build_changeset(6, 13, (0...6).to_a + " world!".split('')) }
  let(:set3) { build_changeset(6, 5,  (0...5).to_a) }
  let(:set4) { build_changeset(6, 12, (0...5).to_a + " world!".split('')) }
  let(:set5) { build_changeset(7, 13, (0...7).to_a + " world!".split('')) }

  def build_changeset(before, after, changes)
    Changeset.new(length_before: before, length_after: after, changes: changes)
  end

  describe 'compose_with' do
    it 'can compose additions' do
      result = set1.compose_with(set2)
      expect(result.length_before).to eq set1.length_before
      expect(result.length_after).to  eq set2.length_after
      expect(result.changes).to eq "hello! world!".split('')
    end

    it 'can compose subtractions' do
      result = set1.compose_with(set3)
      expect(result.length_before).to eq set1.length_before
      expect(result.length_after).to  eq set3.length_after
      expect(result.changes).to eq "hello".split('')
    end

    it 'can compose additions with subtractions' do
      result = set1.compose_with(set4)
      expect(result.length_before).to eq set1.length_before
      expect(result.length_after).to  eq set4.length_after
      expect(result.changes).to eq "hello world!".split('')
    end

    it 'can compose in reverse' do
      result = set4.compose_with(set1)
      expect(result.length_before).to eq set1.length_before
      expect(result.length_after).to  eq set4.length_after
      expect(result.changes).to eq "hello world!".split('')
    end

    it 'returns nil when no composition is possible' do
      result = set1.compose_with(set5)
      expect(result).to be_nil
    end
  end

  describe 'merge' do
  end
end
