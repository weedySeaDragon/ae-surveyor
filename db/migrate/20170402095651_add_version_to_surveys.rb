# encoding: UTF-8
class AddVersionToSurveys < ActiveRecord::Migration[5.0]
  def self.up
    add_column :surveys, :survey_version, :integer, :default => 0
  end

  def self.down
    remove_column :surveys, :survey_version
  end
end
