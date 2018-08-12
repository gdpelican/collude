require './spec/rails_helper'

path = "./plugins/collude/plugin.rb"
source = File.read(path)
plugin = Plugin::Instance.new(Plugin::Metadata.parse(source), path)
plugin.activate!
plugin.initializers.first.call
