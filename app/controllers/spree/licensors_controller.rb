module Spree
  class LicensorsController < Spree::StoreController

    include Spree::LicensorsHelper

    def show

      # If user is not signed in, or is not a licensor, redirect to home page
      unless spree_current_user.present? && spree_current_user.licensor.present?
        redirect_to root_path
        return
      end

      @licensor = spree_current_user.licensor

      unless params[:updated_at_gt].blank? || params[:updated_at_lt].blank?
        updated_at_gt = Time.zone.parse(params[:updated_at_gt]).beginning_of_day
        updated_at_lt = Time.zone.parse(params[:updated_at_lt]).end_of_day
        include_samples = params[:include_samples] == '1'

        unless valid_date_range? updated_at_gt, updated_at_lt
          flash[:error] = 'Start date must be earlier than end date.'
          redirect_to licensor_path
          return
        end

        @orders = Spree::Order.licensor_report @licensor.taxon_id, updated_at_gt, updated_at_lt, include_samples
      end

    end

  end
end
