class Collusion < PostCustomField
  validates        :user,      presence: true
  validates        :post,      presence: true
  validates        :changeset, presence: true
  validates        :version,   numericality: { greater_than: 0 }
  after_initialize :set_name

  default_scope { where(name: :collusion) }

  def self.collusion_accessor(*fields)
    Array(fields).each do |field|
      define_method field,        ->      { collusion[field.to_s] }
      define_method :"#{field}=", ->(val) { collusion[field.to_s] = val }
    end
  end
  collusion_accessor :user_id, :version

  def self.spawn(post:, user:, changeset:)
    create(
      user:      user,
      post:      post,
      version:   post.latest_collusion.version + 1,
      changeset: changeset,
      value:     changeset.apply_to(post.latest_collusion)
    ) if post.can_collude?
  end

  def changeset
    @changeset ||= Changeset.new(collusion['changeset'].to_h)
  end

  def changeset=(value)
    collusion['changeset'] = value
  end


  def user
    @user ||= User.find_by(id: user_id)
  end


  def user=(u)
    self.user_id = u.id
  end

  def set_name
    self.name ||= :collusion
  end
end
