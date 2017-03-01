class CreateThinkspaceResource < ActiveRecord::Migration
  def change

    create_table :thinkspace_resource_file_tags, force: true do |t|
      t.references  :file
      t.references  :tag
      t.timestamps
      t.index  [:file_id],                      name: :idx_thinkspace_resource_file_tags_on_file
      t.index  [:tag_id],                       name: :idx_thinkspace_resource_file_tags_on_tag
    end

    create_table :thinkspace_resource_files, force: true do |t|
      t.references  :user
      t.references  :resourceable, polymorphic: true
      t.string      :file_file_name
      t.string      :file_content_type
      t.integer     :file_file_size
      t.datetime    :file_updated_at
      t.timestamps
      t.index  [:user_id],                              name: :idx_thinkspace_resource_files_on_user
      t.index  [:resourceable_id, :resourceable_type],  name: :idx_thinkspace_resource_files_on_resourceable
    end

    create_table :thinkspace_resource_link_tags, force: true do |t|
      t.references  :link
      t.references  :tag
      t.timestamps
      t.index  [:link_id],                      name: :idx_thinkspace_resource_link_tags_on_link
      t.index  [:tag_id],                       name: :idx_thinkspace_resource_link_tags_on_tag
    end

    create_table :thinkspace_resource_links, force: true do |t|
      t.references  :user
      t.references  :resourceable, polymorphic: true
      t.string      :title
      t.string      :url
      t.timestamps
      t.index  [:user_id],                              name: :idx_thinkspace_resource_links_on_user
      t.index  [:resourceable_id, :resourceable_type],  name: :idx_thinkspace_resource_links_on_resourceable
    end

    create_table :thinkspace_resource_tags, force: true do |t|
      t.references  :user
      t.references  :taggable, polymorphic: true
      t.string      :title
      t.timestamps
      t.index  [:user_id],                      name: :idx_thinkspace_resource_tags_on_user
      t.index  [:taggable_id, :taggable_type],  name: :idx_thinkspace_resource_tags_on_taggable
    end

  end
end
