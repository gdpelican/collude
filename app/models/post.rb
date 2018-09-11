class ::Post
  has_many :collusions, -> { where(name: :collusion) }

  def can_collude?
    post_number == 1 && topic&.archetype == Archetype.default
  end

  def latest_collusion
    return unless can_collude?
    self.collusions.find_by("(collusion ->>'version')::integer = ?", max_collusion_version) || setup_initial_collusion!
  end

  private

  def setup_initial_collusion!
    self.collusions.create!(
      user:    self.user,
      value:   self.raw,
      version: 1,
      changeset: ChangesetSerializer.new(initial_changeset).as_json
    ) if can_collude?
  end

  def initial_changeset
    Changeset.new(
      length_before: 0,
      length_after: self.raw.to_s.length,
      changes: Array([self.raw, self.user_id].join("ØØ"))
    )
  end

  def max_collusion_version
    self.collusions.maximum("(collusion ->>'version')::integer") if can_collude?
  end
end
