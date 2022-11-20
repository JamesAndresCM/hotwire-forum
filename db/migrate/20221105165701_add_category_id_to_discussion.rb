class AddCategoryIdToDiscussion < ActiveRecord::Migration[7.0]
  def change
    add_column :discussions, :category_id, :bigint
    add_index :discussions, :category_id
  end
end
