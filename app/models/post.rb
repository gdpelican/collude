class ::Post
  has_many :collusions, -> { where(name: :collusion) }

  def max_collusion_version
    @max_collusion_version ||= self.collusions.maximum("collusion ->>'version'")
  end

  def latest_collusion
    if !max_collusion_version.nil?
      self.collusions.find_by("collusion ->>'version' = ?", max_collusion_version)
    else
      self.collusions.create!(
        user:    self.user,
        value:   self.raw,
        version: 1,
        changeset: Changeset.new(
          length_before: 0,
          length_after:  self.raw.length,
          changes:       self.raw.split('')
        ).to_json
      )
    end
  end
end
