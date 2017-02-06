Spree::Order.class_eval do

  require 'csv'

  class << self

    # For reporting, get count and total of all completed orders for licensors within a date range
    def licensors_summary updated_at_gt, updated_at_lt, include_samples

      data = []

      samples_sql = include_samples ? '' : "AND V.sku NOT LIKE '%_sample'"
      licensors.each do |licensor|

        taxon_products = licensor.products
        child_products = licensor.children.includes(:products).map(&:products).flatten.compact.uniq
        products = taxon_products + child_products
        product_ids = products.map(&:id).join(',')

        sql = "SELECT
          COUNT(O.id) AS order_count,
          SUM(L.quantity * L.price) AS order_total
        FROM
          spree_orders O
          INNER JOIN spree_line_items L ON O.id = L.order_id
          INNER JOIN spree_variants V ON L.variant_id = V.id
          INNER JOIN spree_products P ON V.product_id = P.id
        WHERE
          P.id IN(#{product_ids})
          AND O.state = 'complete'
          AND O.completed_at BETWEEN '#{updated_at_gt}' AND '#{updated_at_lt}'
          #{samples_sql}"

        res = ActiveRecord::Base.connection.execute(sql)[0]
        data << { id: licensor.id, name: licensor.licensor.present? ? licensor.licensor.name : licensor.name, order_count: res['order_count'], order_total: res['order_total'] }

      end

      data

    end

    # For export to a CSV file, get all completed orders for featured designers within a date range
    def featured_designers_csv updated_at_gt, updated_at_lt, include_samples

      data = []

      samples_sql = include_samples ? '' : "AND V.sku NOT LIKE '%_sample'"
      featured_designers.each do |designer|

        taxon_products = designer.products
        child_products = designer.children.includes(:products).map(&:products).flatten.compact.uniq
        products = taxon_products + child_products
        product_ids = products.map(&:id).join(',')

        sql = "SELECT
            O.id AS order_id,
            P.name AS product_name,
            V.sku,
            V.id AS variant_id,
            L.quantity,
            L.price
          FROM
            spree_orders O
            INNER JOIN spree_line_items L ON O.id = L.order_id
            INNER JOIN spree_variants V ON L.variant_id = V.id
            INNER JOIN spree_products P ON V.product_id = P.id
          WHERE
            P.id IN(#{product_ids})
            AND O.state = 'complete'
            AND O.completed_at BETWEEN '#{updated_at_gt}' AND '#{updated_at_lt}'
            #{samples_sql}
          ORDER BY
            P.name,
            V.sku,
            V.id"

        res = ActiveRecord::Base.connection.execute(sql)

        res.each do |row|
          data << {
              order_id: row['order_id'],
              designer_name: designer.name,
              product_name: row['product_name'],
              sku: row['sku'],
              variant_id: row['variant_id'],
              quantity: row['quantity'],
              price: row['price']
          }
        end

      end

      data

    end

    # Export all completed orders for featured designers within a date range
    def featured_designers_to_csv updated_at_gt, updated_at_lt, include_samples
      data = self.featured_designers_csv updated_at_gt, updated_at_lt, include_samples
      attributes = %w[order_id designer_name product_name sku variant_id quantity price]
      CSV.generate(headers: true) do |csv|
        csv << attributes
        data.each do |row|
          item = OpenStruct.new(row)
          csv << attributes.map{ |attr| item.send(attr) }
        end
      end
    end

    # For reporting, get all completed orders for a licensor within a date range
    def licensor_report taxon_id, updated_at_gt, updated_at_lt, include_samples

      licensor = Spree::Taxon.find(taxon_id)
      taxon_products = licensor.products
      child_products = licensor.children.includes(:products).map(&:products).flatten.compact.uniq
      products = taxon_products + child_products
      product_ids = products.map(&:id).join(',')

      samples_sql = include_samples ? '' : "AND V.sku NOT LIKE '%_sample'"

      sql = "SELECT
        O.id AS order_id,
        P.name AS product_name,
        V.sku,
        L.quantity,
        L.price
      FROM
        spree_orders O
        INNER JOIN spree_line_items L ON O.id = L.order_id
        INNER JOIN spree_variants V ON L.variant_id = V.id
        INNER JOIN spree_products P ON V.product_id = P.id
      WHERE
        P.id IN(#{product_ids})
        AND O.state = 'complete'
        AND O.completed_at BETWEEN '#{updated_at_gt}' AND '#{updated_at_lt}'
        #{samples_sql}
      ORDER BY
        P.name,
        V.sku,
        V.id"

      res = ActiveRecord::Base.connection.execute(sql)

      data = []

      res.each do |row|
        data << {
            order_id: row['order_id'],
            product_name: row['product_name'],
            sku: row['sku'],
            quantity: row['quantity'],
            price: row['price']
        }
      end

      data

    end

    # Export all completed orders for a licensor within a date range
    def licensor_to_csv taxon_id, updated_at_gt, updated_at_lt, include_samples
      data = self.licensor_report taxon_id, updated_at_gt, updated_at_lt, include_samples
      attributes = %w[order_id product_name sku quantity price]
      CSV.generate(headers: true) do |csv|
        csv << attributes
        data.each do |row|
          item = OpenStruct.new(row)
          csv << attributes.map{ |attr| item.send(attr) }
        end
      end
    end


    # def licensors
    #   return self.featured_designers << self.panoramic_murals
    #   # [self.panoramic_murals]
    # end
    #
    #
    # def featured_designers
    #   taxon = Spree::Taxon.find_by(name: 'Featured Designers', parent: Spree::Taxon.find_by(name: 'Categories'))
    #   Spree::Taxon.where(parent: taxon).order(:name)
    # end
    #
    # def panoramic_murals
    #   Spree::Taxon.find_by(name: 'Custom Sized Landscape Murals', parent: Spree::Taxon.find_by(name: 'Wall Murals'))
    # end


    # For reporting, get count  and total of all completed orders for panoramic murals within a date range
    def panoramic_murals_report updated_at_gt, updated_at_lt

      taxon = Spree::Taxon.find_by(name: 'Custom Sized Landscape Murals', parent: Spree::Taxon.find_by(name: 'Wall Murals'))
      self.licensor_report(taxon.id)

    end

    # Export all completed orders for panoramic murals within a date range
    def panoramic_murals_to_csv updated_at_gt, updated_at_lt
      data = self.panoramic_murals_report updated_at_gt, updated_at_lt
      attributes = %w[order_id product_name sku quantity price]
      CSV.generate(headers: true) do |csv|
        csv << attributes
        data.each do |row|
          item = OpenStruct.new(row)
          csv << attributes.map{ |attr| item.send(attr) }
        end
      end
    end

  end

end
