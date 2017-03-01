class CreateThinkspacePubSub < ActiveRecord::Migration
  def change

    create_table :thinkspace_pub_sub_server_events, force: true do |t|
      t.references  :authable,  polymorphic: true
      t.references  :user
      t.string      :state
      t.string      :origin
      t.string      :channel
      t.string      :event
      t.string      :room_event
      t.jsonb       :rooms
      t.json        :value
      t.json        :records
      t.json        :timer_settings
      t.datetime    :timer_start_at
      t.datetime    :timer_end_at
      t.datetime    :timer_cancelled_at
      t.timestamps
      t.index  [:state],         name: :idx_thinkspace_pub_sub_server_events_on_state
      t.index  [:user_id],       name: :idx_thinkspace_pub_sub_server_events_on_user
      t.index  [:channel],       name: :idx_thinkspace_pub_sub_server_events_on_channel
      t.index  [:room_event],    name: :idx_thinkspace_pub_sub_server_events_on_room_event
      t.index  [:event],         name: :idx_thinkspace_pub_sub_server_events_on_event
      t.index  [:timer_end_at],  name: :idx_thinkspace_pub_sub_server_events_on_end_at
      t.index  [:created_at],    name: :idx_thinkspace_pub_sub_server_events_on_created_at
      t.index  [:rooms],         name: :idx_thinkspace_pub_sub_server_events_on_rooms, using: :gin
      t.index  [:authable_id, :authable_type], name: :idx_thinkspace_pub_sub_server_events_on_authable
    end

  end
end
