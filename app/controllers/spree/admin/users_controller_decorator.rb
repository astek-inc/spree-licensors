Spree::Admin::UsersController.class_eval do
  before_action :set_licensor_data, only: [:edit]

  private

  def set_licensor_data
    @licensor = Spree::Licensor.find_by(user_id: params[:id]) || Spree::Licensor.new(user_id: params[:id])
    @licensor_taxons = Spree::Taxon.licensors
  end
end
