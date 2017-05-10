class Document < ActiveRecord::Base

  require 'tempfile'

  attr_accessible :comment, :status, :keywords, :keyword_list, :page_count,:pages_attributes, :delete_at, :no_delete, :created_at, :cover_id, :folder_id
  has_many :pages, :order => :position, :dependent => :destroy
  belongs_to :folder
  belongs_to :cover

  accepts_nested_attributes_for :pages, :allow_destroy => true
  acts_as_taggable_on :keywords

  ### Thinking Sphinx
  after_commit :set_delta_flag

  before_update :update_status_new_document
  before_save :update_expiration_date
  before_destroy :check_no_delete


  #### Status
  DOCUMENT=0 ##document was created based on an uploaded document
  DOCUMENT_FROM_PAGE_REMOVED = 1 ##document was created, as a page was removed from an existing doc

  def pdf_file
    docs='';self.pages.each  {|p| docs+=' '+p.path(:org)}
    pdf=Tempfile.new(["cd_#{self.id}",".pdf"])
    java_merge_pdf="java -classpath './java_itext/.:./java_itext/itext-5.3.5/*' MergePDF"
    res=%x[#{java_merge_pdf} #{docs} #{pdf.path}]
    return pdf
  end

    def backup?
    self.pages.where("backup = 0").count==0
  end

  def update_after_page_change
    self.page_count=self.pages.count

    ### if documents has pages with non-pdf-mime type, no complete PDF page can be generated
    if self.pages.where("mime_type <> '#{Page::PAGE_MIME_TYPES.key(:PDF)}'").count>0
        self.complete_pdf=false
    else
      self.complete_pdf=true
      end

    self.save!

  end


  def check_no_delete
    if self.no_delete?
      Log.write_error('MAJOR ERROR', "System tried to delete -NO_DELETE- document with id:#{self.id}")
      raise "ERROR: System tried to delete -NO_DELETE- document with id:#{self.id}"
    end
  end

  # a summary page can only be displayed
  def show_summary_page?
    return true if (self.no_complete_pdf==false or self.page_count==1)
    return false
  end

  private

##http://stackoverflow.com/questions/4902804/using-delta-indexes-for-associations-in-thinking-sphinx


  def set_delta_flag
    self.pages.update_all("delta=1")
    Page.define_indexes
    Page.index_delta
  end

  def update_status_new_document
    self.status=DOCUMENT if self.status_was==DOCUMENT_FROM_PAGE_REMOVED
  end

  def update_expiration_date
    self.delete_at=nil if self.delete_at==Date.new(3000) #to allow reset the date back to null (newer expire)
  end
### https://github.com/mperham/sidekiq/blob/master/examples/clockwork.rb
end