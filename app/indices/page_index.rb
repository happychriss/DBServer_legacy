ThinkingSphinx::Index.define( :page, :with => :active_record,  :delta => true)  do

    indexes content, :as => :content
    indexes document.comment, :as => :document_comment

    has status
    has position, :as => :position, :sortable => true
    has id, :as => :page_id, :sortable => true

    has document.taggings.tag_id, :as => :tags
    has document.status, :as => :document_status
    has document.created_at, :as => :document_created_at, :sortable => true
    has document.page_count
    has document.complete_pdf
    has document_id, :as => :group_document

    where "document_id is not null"

end