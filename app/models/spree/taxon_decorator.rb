Spree::Taxon.class_eval do
  has_one :licensor

  class << self

    def licensors
      return (self.featured_designers << self.panoramic_images).sort_by { |taxon| taxon.name }
    end

    def featured_designers
      taxon = self.find_by(name: 'Featured Designers', parent: Spree::Taxon.find_by(name: 'Categories'))
      Spree::Taxon.where(parent: taxon).order(:name)
    end

    def panoramic_images
      self.find_by(name: 'Custom Sized Landscape Murals', parent: Spree::Taxon.find_by(name: 'Wall Murals'))
    end

  end
end
