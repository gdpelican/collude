class CollusionSerializer < ActiveModel::Serializer
  attributes :version, :user_id, :post_id, :value, :changeset
end
