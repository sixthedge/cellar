module Thinkspace
  module Resource
    module Concerns
      module Clone
        module Resources

          def clone_record_resources(record, dictionary, options={})
            record.thinkspace_resource_files.each do |file|
              ufile       = file.get_updateable
              cloned_file = ufile.deep_clone include: [:resourceable], dictionary: dictionary
              clone_save_record(cloned_file)
              clone_resource_paperclip_file(file, cloned_file)
            end
            record.thinkspace_resource_links.each do |link|
              ulink       = link.get_updateable
              cloned_link = ulink.deep_clone include: [:resourceable], dictionary: dictionary
              clone_save_record(cloned_link)
            end
            record.thinkspace_resource_tags.each do |tag|
              utag       = tag.get_updateable
              cloned_tag = utag.deep_clone include: [:taggable], dictionary: dictionary
              clone_save_record(cloned_tag)
              # Clone the tag's 'through' tables for files and links.
              tag.thinkspace_resource_file_tags.each do |file_tag|
                cloned_file_tag = file_tag.deep_clone include: [:thinkspace_resource_tag, :thinkspace_resource_file], dictionary: dictionary
                clone_save_record(cloned_file_tag)
              end
              tag.thinkspace_resource_link_tags.each do |link_tag|
                cloned_link_tag = link_tag.deep_clone include: [:thinkspace_resource_tag, :thinkspace_resource_link], dictionary: dictionary
                clone_save_record(cloned_link_tag)
              end
            end
          end

          def clone_resource_paperclip_file(file, cloned_file)
            cloned_file.file = file.file
            clone_save_record(cloned_file)
          end

        end
      end
    end
  end
end
