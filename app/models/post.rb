class ::Post
  has_many :collusions, -> { where(name: :collusion) }

  def can_collude?
    post_number == 1 && topic&.archetype == Archetype.default
  end

  def latest_collusion
    return unless can_collude?
    self.collusions.find_by("collusion ->>'version' = ?", max_collusion_version) || setup_initial_collusion!
  end

  private

  def setup_initial_collusion!
    self.collusions.create!(
      user:    self.user,
      value:   self.raw,
      version: 1,
      changeset: ChangesetSerializer.new(Changeset.from_raw(self.raw)).as_json
    ) if can_collude?
  end

  def max_collusion_version
    return unless can_collude?
    @max_collusion_version ||= self.collusions.maximum("collusion ->>'version'")
  end
end
