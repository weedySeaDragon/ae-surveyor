# encoding: UTF-8
class AddDefaultValueToAnswers < ActiveRecord::Migration[5.0]
  def self.up
    add_column :answers, :default_value, :string
  end

  def self.down
    remove_column :answers, :default_value
  end
end
