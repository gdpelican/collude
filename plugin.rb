# name: collude
# about: Collaborative document editing for Discourse
# version: 0.0.1
# authors: James Kiesel (gdpelican)
# url: https://github.com/gdpelican/collude

def collude_require(path)
  require Rails.root.join('plugins', 'collude', 'app', path)
end

after_initialize do
  collude_require 'controllers/collusions_controller'
  collude_require 'models/changeset'
  collude_require 'models/collusion'
  collude_require 'models/post'
  collude_require 'serializers/collusion_serializer'
  collude_require 'routes'

  # if !PostCustomField.new.respond_to?(:collusion)
  #   collude_require 'migrations/add_collusions'
  #   AddCollusions.new.up
  # end

  on :post_created do |post|
    Jobs.enqueue(:setup_initial_collusion, post_id: post.id) if post.can_collude?
  end
end
