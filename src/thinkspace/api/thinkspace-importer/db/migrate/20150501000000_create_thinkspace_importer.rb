class CreateThinkspaceImporter < ActiveRecord::Migration
  def change

    create_table :thinkspace_importer_files, force: true do |t|
      t.references  :user
      t.references  :importable, polymorphic: true
      t.string      :custom_url
      t.string      :generated_model
      t.string      :attachment_file_name
      t.string      :attachment_content_type
      t.integer     :attachment_file_size
      t.datetime    :attachment_updated_at
      t.json        :settings
      t.timestamps
      t.index  [:user_id],  name: :idx_thinkspace_importer_files_on_user
    end

  end
end

