# encoding: UTF-8
class AddSectionIdToResponses < ActiveRecord::Migration[5.0]
  def self.up
    add_column :responses, :survey_section_id, :integer
    add_index :responses, :survey_section_id
  end

  def self.down
    remove_index :responses, :survey_section_id
    remove_column :responses, :survey_section_id
  end
end
