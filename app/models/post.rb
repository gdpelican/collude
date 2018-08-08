class ::Post
  has_many :collusions, -> { where(name: :collusion) }

  def max_collusion_version
    self.collusions.maximum(:version)
  end

  def latest_collusion
    self.collusions.find_by("collusion ->>'version' = ?", max_collusion_version)
  end
end
