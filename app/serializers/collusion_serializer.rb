class CollusionSerializer < ActiveModel::Serializer
  attributes :version, :user_id, :post_id, :length, :value, :changeset
end
