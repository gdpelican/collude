Changeset = Struct.new(:length_before, :length_after, :changes, keyword_init: true) do

  def apply_to(collusion)
    if needs_merge?(collusion) then merge(collusion) else apply(collusion) end
  end

  def to_json(opts = {})
    {
      length_before: length_before.to_i,
      length_after:  length_after.to_i,
      changes:       Array(changes)
    }
  end

  private

  def range_from(change)
    Range.new(*change[2..-1].split('-').map(&:to_i)) if change[0..1] == 'øø'
  end

  def needs_merge?(collusion)
    collusion.value.length != self.length_before
  end

  def apply(collusion)
    self.changes.reduce("") do |value, change|
      value + if range = range_from(change)
        collusion.value[range]
      else
        change
      end
    end
  end

  def merge(collusion)
    # TODO
  end
end
