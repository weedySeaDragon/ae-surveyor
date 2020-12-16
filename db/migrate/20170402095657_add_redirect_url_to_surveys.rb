# encoding: UTF-8
class AddRedirectUrlToSurveys < ActiveRecord::Migration[5.0]
  def self.up
    add_column :surveys, :redirect_url, :string
  end

  def self.down
    remove_column :surveys, :redirect_url
  end
end
