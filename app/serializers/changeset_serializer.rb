class ChangesetSerializer < ActiveModel::Serializer
  root false
  attributes :length_before, :length_after, :changes
end
