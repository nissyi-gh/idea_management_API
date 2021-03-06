# frozen_string_literal: true

# Categoryテーブルのnameにindexを追加
class AddIndexToCategory < ActiveRecord::Migration[6.1]
  def change
    add_index :categories, :name, unique: true
  end
end
