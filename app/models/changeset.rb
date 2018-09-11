Changeset = Struct.new(:length_before, :length_after, :changes, keyword_init: true) do
  alias :read_attribute_for_serialization :send

  def apply_to(collusion)
    if collusion.value.length != self.length_before
      Collude::Merger.new(self, collusion).merge!
    else
      Collude::Applier.new(self, collusion).apply!
    end
  end
end
