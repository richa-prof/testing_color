class AddHighlightColorToBook < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :highlight_color, :string
  end
end
