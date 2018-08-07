# name: collude
# about: Collaborative document editing for Discourse
# version: 0.0.1
# authors: James Kiesel (gdpelican)
# url: https://github.com/gdpelican/collude

def collude_require(path)
  require Rails.root.join('plugins', 'collude', 'app', path)
end

after_initialize do
  collude_require 'controllers/posts_controller'
  collude_require 'models/collusion'
  collude_require 'routes'

  if !PostCustomField.new.respond_to?(:collusion)
    collude_require 'migrations/add_collusions'
    AddCollusions.new.up
  end
end
