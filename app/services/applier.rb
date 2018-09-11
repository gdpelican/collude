module Collude
  class Applier
    def initialize(changeset, collusion)
      @changeset = changeset
      @collusion = collusion
    end

    def apply!
      @changeset.changes.reduce("") do |value, change|
        value + if range = range_from(change)
          @collusion.value[range]
        else
          change
        end
      end
    end

    private

    def range_from(change)
      Range.new(*change[2..-1].split('-').map(&:to_i)) if change[0..1] == 'øø'
    end
  end
end
