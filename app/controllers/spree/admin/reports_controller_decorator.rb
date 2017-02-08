Spree::Admin::ReportsController.class_eval do

  before_action :add_licensors_report

  def add_licensors_report
    Spree::Admin::ReportsController.add_available_report!(:licensors)
  end

  def licensors
    return if params[:updated_at_gt].blank? || params[:updated_at_lt].blank?
    updated_at_gt = Time.zone.parse(params[:updated_at_gt]).beginning_of_day
    updated_at_lt = Time.zone.parse(params[:updated_at_lt]).end_of_day
    include_samples = params[:include_samples] == '1'

    @licensors = Spree::Order.licensors_summary updated_at_gt, updated_at_lt, include_samples
  end

  def licensors_csv_export
    return if params[:updated_at_gt].blank? || params[:updated_at_lt].blank?
    updated_at_gt = Time.zone.parse(params[:updated_at_gt]).beginning_of_day
    updated_at_lt = Time.zone.parse(params[:updated_at_lt]).end_of_day
    include_samples = params[:include_samples] == '1'

    with_samples = include_samples ? '_with_samples' : ''
    filename = "licensors_#{params[:updated_at_gt]}-#{params[:updated_at_lt]}#{with_samples}.csv"

    respond_to do |format|
      format.csv { send_data Spree::Order.licensors_to_csv(updated_at_gt, updated_at_lt, include_samples),
                             filename: filename,
                             type: 'text/csv' }
    end
  end

  def licensor
    return if params[:id].blank? || params[:updated_at_gt].blank? || params[:updated_at_lt].blank?

    taxon_id = params[:id]
    updated_at_gt = Time.zone.parse(params[:updated_at_gt]).beginning_of_day
    updated_at_lt = Time.zone.parse(params[:updated_at_lt]).end_of_day
    include_samples = params[:include_samples] == '1'

    @licensor = Spree::Taxon.find(taxon_id)
    @start_date = Date.parse(params[:updated_at_gt]).strftime('%b %-d, %Y')
    @end_date = Date.parse(params[:updated_at_lt]).strftime('%b %-d, %Y')
    @orders = Spree::Order.licensor_report taxon_id, updated_at_gt, updated_at_lt, include_samples
  end

  def licensor_csv_export
    return if params[:id].blank? || params[:updated_at_gt].blank? || params[:updated_at_lt].blank?

    taxon_id = params[:id]
    updated_at_gt = Time.zone.parse(params[:updated_at_gt]).beginning_of_day
    updated_at_lt = Time.zone.parse(params[:updated_at_lt]).end_of_day
    include_samples = params[:include_samples] == '1'

    licensor = Spree::Taxon.find(taxon_id)
    licensor_name = licensor.name.gsub(/\W/, '_').downcase!

    with_samples = include_samples ? '_with_samples' : ''
    filename = "#{licensor_name}_#{params[:updated_at_gt]}-#{params[:updated_at_lt]}#{with_samples}.csv"

    respond_to do |format|
      format.csv { send_data Spree::Order.licensor_to_csv(taxon_id, updated_at_gt, updated_at_lt, include_samples),
                             filename: filename,
                             type: 'text/csv' }
    end
  end

end



