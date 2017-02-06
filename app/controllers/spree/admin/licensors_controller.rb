module Spree
  module Admin
    class LicensorsController < ResourceController

      # def create
      #   @tmp = location_after_save
      #   render 'index'
      # end


      private

      def permitted_resource_params
        params.require(:licensor).permit(:id, :name, :user_id, :taxon_id)
      end

      def location_after_save
        edit_admin_user_path(params[:user_id])
      end

    end
  end
end
