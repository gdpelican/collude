class AddCollusions < ActiveRecord::Migration[5.1]
  def up
    if !column_exists?(:post_custom_fields, :collusion)
      add_column :post_custom_fields, :collusion, :jsonb, default: {}, index: true
    end
  end

  def down
    remove_column :post_custom_fields, :collusion, :jsonb
  end
end
