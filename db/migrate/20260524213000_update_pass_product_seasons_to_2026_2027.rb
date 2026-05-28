class UpdatePassProductSeasonsTo20262027 < ActiveRecord::Migration[8.0]
  class MigrationPassProduct < ActiveRecord::Base
    self.table_name = "pass_products"
  end

  class MigrationPassResortAccess < ActiveRecord::Base
    self.table_name = "pass_resort_accesses"
  end

  def up
    rename_season(from: "2025-2026", to: "2026-2027")
  end

  def down
    rename_season(from: "2026-2027", to: "2025-2026")
  end

  private

  def rename_season(from:, to:)
    MigrationPassProduct.reset_column_information
    MigrationPassResortAccess.reset_column_information

    MigrationPassProduct.where(season: from).find_each do |pass_product|
      target = MigrationPassProduct
        .where(name: pass_product.name, season: to)
        .where.not(id: pass_product.id)
        .first

      if target
        MigrationPassResortAccess
          .where(pass_product_id: pass_product.id)
          .update_all(pass_product_id: target.id)
        pass_product.destroy!
      else
        pass_product.update!(season: to)
      end
    end
  end
end
