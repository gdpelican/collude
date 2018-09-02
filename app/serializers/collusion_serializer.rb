class CollusionSerializer < ActiveModel::Serializer
  attributes :version, :user_id, :post_id, :value, :changeset, :actor_id
  has_one :changeset, serializer: ChangesetSerializer

  def actor_id
    scope&.id
  end
end
