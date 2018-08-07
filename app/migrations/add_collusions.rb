class AddCollusions < ActiveRecord::Migration[5.1]
  def up
    add_column :post_custom_fields, :collusion, :jsonb, default: {}, index: true
  end

  def down
    remove_column :post_custom_fields, :collusion, :jsonb
  end
end
