require './plugins/collude/spec/spec_helper'

describe ::Changeset do
  let(:set1) { build_changeset(0, 6,  ["hello!"]) }
  let(:set2) { build_changeset(6, 13, ["øø0-5", " world!"]) }
  let(:set3) { build_changeset(6, 5,  ["øø0-4"]) }
  let(:set4) { build_changeset(6, 12, ["øø0-4", " world!"]) }
  let(:set5) { build_changeset(7, 13, ["øø0-6", " world!"]) }
  let(:set6) { build_changeset(6, 6, ["el", "øø2-2", "o!!"]) }

  let(:set2_merge) { build_changeset(5, 11, ["øø0-4", " dog!"]) }
  let(:needs_merge) { Collusion.new(value: "hello world!", changeset: set2) }

  def build_changeset(before, after, changes)
    Changeset.new(length_before: before, length_after: after, changes: changes)
  end

  describe 'full_change_array' do
    it 'can interpret a changes representation' do
      expect(set1.full_change_array).to eq ['h','e','l','l','o','!']
      expect(set2.full_change_array).to eq [0,1,2,3,4,5,' ','w','o','r','l','d','!']
      expect(set3.full_change_array).to eq [0,1,2,3,4]
      expect(set4.full_change_array).to eq [0,1,2,3,4,' ','w','o','r','l','d','!']
      expect(set5.full_change_array).to eq [0,1,2,3,4,5,6,' ','w','o','r','l','d','!']
    end
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

    it 'can handle in-place changes' do
      result = set1.compose_with(set6)
      expect(result.length_before).to eq set1.length_before
      expect(result.length_after).to eq set6.length_after
      expect(result.changes).to eq "ello!!".split('')
    end
  end

  describe 'merge' do
    it 'can handle a merge with a deletion' do
      expect(set2_merge.apply_to(needs_merge)).to eq "hello dog! world!"
    end
  end
end
