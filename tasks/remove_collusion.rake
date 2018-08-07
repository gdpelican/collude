def require_rel(path)
  require File.expand_path(File.dirname(__FILE__) + path)
end
require_rel '/../../../config/environment'

desc "remove collusion changes from database"
task "collude:remove" do
  require_rel '/../app/migrations/add_collusions'
  AddCollusions.new.down
end
