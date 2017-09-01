# This migration comes from thinkspace_report (originally 20160822000001)
class CreateThinkspaceReportReports < ActiveRecord::Migration
  def change

    create_table :thinkspace_report_reports, force: true do |t|
      t.string      :title
      t.references  :user
      t.references  :authable, polymorphic: true
      t.json        :value
      t.timestamps
      t.index  [:user_id],  name: :idx_thinkspace_report_reports_on_user
      t.index  [:authable_type, :authable_id],  name: :idx_thinkspace_report_reports_on_authable
    end

  end
end

