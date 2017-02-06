module Spree
  class Licensor < Spree::Base

    acts_as_paranoid

    belongs_to :user
    belongs_to :taxon

    validates :name, presence: true
    validates :user, presence: true
    validates :taxon, presence: true

  end
end
