Changeset = Struct.new(:length_before, :length_after, :changes, keyword_init: true) do

  def compose_with(other)
    self.compose(other) || other.compose(self)
  end

  def apply_to(body)
    return if self.length_before != body.length
    self.changes.map { |change| change.is_a?(Integer) ? body[change] : change }
  end

  def to_json
    {
      length_before: length_before.to_i,
      length_after:  length_after.to_i,
      changes:       Array(changes)
    }
  end

  def compose(other)
    Changeset.new(
      length_before: other.length_before,
      length_after:  self.length_after,
      changes: (0...self.length_after).map { |index|
        (self.changes[index] unless self.changes[index].is_a?(Integer)) ||
        (other.changes[index] unless other.changes[index].is_a?(Integer)) ||
        index
      }
    ) if self.length_before == other.length_after
  end

  private

  def merge(other)
    # ??
  end
end
