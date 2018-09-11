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
  collude_require 'lib/guardian/post_guardian'
  collude_require 'models/changeset'
  collude_require 'models/collusion'
  collude_require 'models/post'
  collude_require 'jobs/collude'
  collude_require 'serializers/changeset_serializer'
  collude_require 'serializers/collusion_serializer'
  collude_require 'services/applier'
  collude_require 'services/merger'
  collude_require 'services/scheduler'
  collude_require 'routes'

  register_post_custom_field_type 'collude', :boolean

  add_to_serializer :post, :collude do
    object.is_first_post? && object.custom_fields['collude']
  end

  if !PostCustomField.new.respond_to?(:collusion)
    collude_require 'migrations/add_collusions'
    AddCollusions.new.up
  end
end
