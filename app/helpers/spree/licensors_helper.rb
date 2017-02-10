module Spree
  module LicensorsHelper

    def valid_date_range? start_date, end_date
      start_date < end_date
    end

  end
end
