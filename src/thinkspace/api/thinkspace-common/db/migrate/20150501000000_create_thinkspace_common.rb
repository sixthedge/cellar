class CreateThinkspaceCommon < ActiveRecord::Migration
  def change

    create_table :thinkspace_common_api_sessions, force: true do |t|
      t.references  :user
      t.string      :authentication_token
      t.timestamps
      t.index  [:user_id], name: :idx_thinkspace_common_api_sessions_on_user
    end

    create_table :thinkspace_common_components, force: true do |t|
      t.string      :title
      t.text        :description
      t.json        :value
      t.json        :preprocessors
      t.timestamps
      t.index  [:title], name: :idx_thinkspace_common_components_on_title
    end

    create_table :thinkspace_common_configurations, force: true do |t|
      t.references  :configurable, polymorphic: true
      t.json        :settings, default: {}
      t.timestamps
      t.index  [:configurable_id, :configurable_type],  name: :idx_thinkspace_common_configurations_on_configurable
    end

    create_table :thinkspace_common_space_space_types, force: true do |t|
      t.references  :space
      t.references  :space_type
      t.timestamps
      t.index  [:space_id],         name: :idx_thinkspace_common_space_space_types_on_space
      t.index  [:space_type_id],    name: :idx_thinkspace_common_space_space_types_on_space_type
    end

    create_table :thinkspace_common_space_types, force: true do |t|
      t.string      :title
      t.string      :lookup_model
      t.timestamps
    end

    create_table :thinkspace_common_space_users, force: true do |t|
      t.references  :space
      t.references  :user
      t.string      :role
      t.timestamps
      t.index  [:space_id, :user_id],   name: :idx_thinkspace_common_space_users_on_space_user
    end

    create_table :thinkspace_common_spaces, force: true do |t|
      t.string      :title
      t.timestamps
    end
    
    create_table :thinkspace_common_users, force: true do |t|
      t.references  :oauth_user
      t.string      :oauth_access_token
      t.string      :first_name
      t.string      :last_name
      t.string      :email,  default: "", null: false
      t.timestamps
      t.index  [:email],      name: :idx_thinkspace_common_users_on_email
    end

  end
end
