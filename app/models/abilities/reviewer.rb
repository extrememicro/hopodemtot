module Abilities
  class Reviewer
    include CanCan::Ability

    def initialize(user)
      self.merge Abilities::Common.new(user)
      can :manage, ActionPlan
    end
  end
end
