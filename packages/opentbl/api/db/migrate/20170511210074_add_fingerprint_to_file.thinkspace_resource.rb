# This migration comes from thinkspace_resource (originally 20150502000000)
class AddFingerprintToFile < ActiveRecord::Migration
  def change
    add_column :thinkspace_resource_files, :file_fingerprint, :string
  end
end
