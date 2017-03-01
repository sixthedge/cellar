class CreateThinkspaceReportReportTokens < ActiveRecord::Migration
  def change

    create_table :thinkspace_report_report_tokens, force: true do |t|
      t.string      :token
      t.datetime    :expires_at
      t.references  :report
      t.references  :user
      t.timestamps
      t.index  [:token],    name: :idx_thinkspace_report_report_tokens_on_token
      t.index  [:user_id],    name: :idx_thinkspace_report_report_tokens_on_user
      t.index  [:report_id],  name: :idx_thinkspace_report_report_tokens_on_report
    end

  end
end

