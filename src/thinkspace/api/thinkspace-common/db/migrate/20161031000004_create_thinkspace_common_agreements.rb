class CreateThinkspaceCommonAgreements < ActiveRecord::Migration
  def change
    create_table :thinkspace_common_agreements, force: true do |t|
      t.string   :doc_type
      t.datetime :effective_at
      t.string   :link

      t.timestamps
    end
  end
end