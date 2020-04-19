class Page < ActiveRecord::Base

  ## adds function short_path and path to page
  require 'FileSystem'
  require 'aws/s3'

  include FileSystem
  include ThinkingSphinx::Scopes

  #
  # sphinx_scope(:weight) {
  #       {:field_weights => {:document_comment => 2, :content => 1}}
  # }
  #
  # default_sphinx_scope :weight

  attr_accessible :content, :document_id, :original_filename, :position, :source, :upload_file, :status, :mime_type, :preview
  attr_accessor :upload_file

  belongs_to :document
  belongs_to :org_folder, :class_name => 'Folder'
  belongs_to :org_cover, :class_name => 'Cover'


  #### Page Status flow
  UPLOADED = 0 # page just uploaded, waiting for processing
  UPLOADED_PROCESSING = 1 # pages is being processed (OCR)
  UPLOADED_PROCESSED = 3 # pages was processed by worker (content added)


  PAGE_SOURCE_SCANNED=0
  PAGE_SOURCE_UPLOADED=1
  PAGE_SOURCE_MOBILE=2
  PAGE_SOURCE_MIGRATED=99

  PAGE_FORMAT_PDF=0
  PAGE_FORMAT_SCANNED_JPG=1

  PAGE_PREVIEW = 1
  PAGE_NO_PREVIEW = 0


  ##
  PAGE_DEFAULT_SCAN_MIME_TYPE = 'application/pdf'

  PAGE_MIME_TYPES={'application/pdf' => :PDF,
                   'application/msword' => :MS_WORD,
                   'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => :MS_WORD,
                   'application/excel' => :MS_EXCEL,
                   'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => :MS_EXCEL,
                   'application/vnd.ms-excel' => :MS_EXCEL,
                   'application/vnd.oasis.opendocument.text' => :ODF_WRITER,
                   'application/vnd.oasis.opendocument.spreadsheet' => :ODF_CALC,
                   'image/jpeg' => :JPG
  }



  ## all pages per folder
  #scope :per_folder, lambda { |fid|
  #  joins("LEFT OUTER JOIN `documents` ON `documents`.`id` = `pages`.`document_id`").joins("LEFT OUTER JOIN folders ON folders.id = documents.folder_id").where("documents.folder_id=#{fid}")
  # }

  ## all pages without  cover
  scope :per_folder_no_cover, lambda { |fid|
    joins(:document).where("cover_id is null and folder_id=#{fid} and pages.status=#{Page::UPLOADED_PROCESSED}")
  }

  scope :per_folder_with_cover, lambda { |fid|
    joins(:document).where("cover_id is not null and folder_id=#{fid} and pages.status=#{Page::UPLOADED_PROCESSED}")
  }


  ## all pages per cover
  scope :per_cover, lambda { |cid|
    joins("LEFT OUTER JOIN documents ON documents.id = pages.document_id").joins("LEFT OUTER JOIN covers ON covers.id = documents.cover_id").where("documents.cover_id=#{cid}")
  }



  def self.get_search_config(page_no, sort_mode)
    search_config = {#:group_by => :group_document, #shows only one page, if  more than one pages per document
#                     :group_function => :attr,
                     :page => page_no,
                     :per_page => 30,
                     :star => true,
                     #           :order => "position ASC" #order in the group
                     #    :without => {:status => [UPLOADED, UPLOADED_PROCESSED]} #pages not yet sorted and ready will be ignored
    }

    # http://rdoc.info/github/freelancing-god/thinking-sphinx/ThinkingSphinx/SearchMethods/ClassMethods
  (search_config.merge!({:order => "created_at desc, id DESC"})) if sort_mode==:time


    return search_config
  end

  ########################################################################################################

  def self.search_index(search_string, keywords, page_no, pages_ignore, sort_mode)
    ###https://groups.google.com/forum/?fromgroups=#!msg/thinking-sphinx/WvOTN6NABN0/vzKnhx5CIvAJ

    search_config = Page.get_search_config(page_no, sort_mode)

    if search_string.nil? or keywords.empty? then
      documents=Document.search_for_ids(search_string, search_config)

      pages=P.search(search_string, search_config)

    else
      search_config.merge!({:with => {:tags => keywords}})
      pages=Page.search(search_string, search_config)
    end


    puts "***************************************************"
    puts "SearchConfig: #{search_config}"
    puts "SearchString: #{search_string}"

    puts "***************************************************"

    ## Pages ignore, are pages that are listed in top of the search results, in order to avoid listing them twice
    pages.delete_if { |p| pages_ignore.index { |pi| pi.id==p.id } }

    return pages

  end

  ########################################################################################################
  ### this page is displayed first in search results with all pages that have been removed from document
  def self.new_document_pages
    pages=Page.search("", Page.get_search_config(1, :relevance).merge!({:with => {:document_status => Document::DOCUMENT_FROM_PAGE_REMOVED}}))
  end

  ########################################################################################################

  def folder
    return nil if self.document.nil?
    return self.org_folder unless self.org_folder_id.nil? or self.org_folder_id==0 ## we have an orginal cover_id, normally for scanned documents
    return self.document.folder
  end

  def cover
    return nil if self.document.nil?
    return self.org_cover unless self.org_cover_id.nil? ## we have an orginal cover_id, normally for scanned documents
    return self.document.cover
  end


  def has_document?
    not self.document.nil?
  end

  ## to read PDF and so on as symbols

  def self.uploading_status(mode)
    result=case mode
             when :no_backup then
               Page.where('backup=false and document_id IS NOT NULL').count
             when :not_processed then
               Page.where("status < #{Page::UPLOADED_PROCESSED}").count
             when :not_converted then
               Page.where("status = #{Page::UPLOADED}").count
             when :processing then
               Page.where("status = #{Page::UPLOADED_PROCESSING}").count
             when :no_ocr then
               Page.where('ocr = false').count
             else
               'ERROR'
           end
  end

  def document_pages_count
    return 0 unless self.has_document?
    self.document.page_count
  end

  def self.uploaded_pages
    self.where("document_id is null")
  end

  def self.for_batch_conversion
    self.where("status = #{Page::UPLOADED}").select('id').map { |x| x.id }
  end

  def destroy_with_file

    self.document.check_no_delete unless self.document.nil? #raise exception if document has no deletion flag

    position=self.position
    last_page=(self.document_pages_count==1)

    Dir.glob(self.path(:all)) do |filename|
      File.delete(filename)
    end

    #### page just uploaded
    if self.document.nil?
      self.destroy
      return last_page
    end

    Document.transaction do

      ## if only one page is left and this is destroyed, destroy document
      if self.document_pages_count==1 then
        self.document.destroy
      else

        document=self.document
        self.destroy

        ### Clean up the document and the remaining pages
        CleanPositionsOnRemove(document.id, position) ## update position of remaining pages
        document.update_after_page_change

      end
    end

    return last_page
    ## return true if this is the last page

  end

  ## remove from document and create a new document
  def move_to_new_document

    ## save all values
    position=self.position
    old_document=self.document

    Page.transaction do
      doc=Document.new(:status => Document::DOCUMENT_FROM_PAGE_REMOVED, :page_count => 1, :folder_id => old_document.folder_id)
      doc.save!
      self.document_id=doc.id
      self.position=0
      self.save!
      CleanPositionsOnRemove(old_document.id, position)
      old_document.update_after_page_change

    end

  end

  ## add new page to a document
  def add_to_document(document, position=document.page_count-1)

    self.transaction do

      old_document_id=self.document_id

      self.document_id=document.id
      self.position=position
      self.save!

      self.document.update_after_page_change

      Document.find(old_document_id).destroy unless old_document_id.nil?

    end

  end


  def preview?
    File.exist?(self.path(:s_jpg))
  end

  def update_status(status)
      self.update_attributes(:status => status)
  end

  ### clean all pages, that got stucked in upload processing, because converter daemon crashed. shall be called when converter daemon connects again
  def self.clean_pending
    Page.where(:status => Page::UPLOADED_PROCESSING).update_all(:status=>Page::UPLOADED)
  end

  def status_text
    status=''
    if self.source==Page::PAGE_SOURCE_MIGRATED
      status= "* Migrated Document stored in FID #{self.fid} *"
    elsif self.document.nil? or (self.document.cover.nil? and self.document.folder.cover_ind?) then
      status= 'No cover created yet'
    elsif not (self.document.folder.cover_ind?)
      status= 'Document is only stored electronically'
    else
      status= "Cover ##{self.document.cover.counter} in #{self.document.cover.created_at.strftime "%B %Y"}"
    end
    status='| '+ status unless status==''
    return status
  end


  ### convert a page into a jpg file

  def jpg_file
    tmp_jpg_file_root=File.join(Dir.tmpdir,"cd_#{self.id}")
    res=%x[pdfimages -l 1 -f 1 -j #{self.path(:org)} #{tmp_jpg_file_root}]

    ## pdfimages adds -000.jpg to the outfile in tmp_jpg_file or pbm if file was converted in with black and white option

    unless File.exist?(tmp_jpg_file_root+'-000.jpg')
      res=%x[convert #{tmp_jpg_file_root}-000.pbm #{tmp_jpg_file_root}-000.jpg]
    end

    return File.open(tmp_jpg_file_root+'-000.jpg')

  end

  ##### mime type is stored in database as long text application/pdf for example

  # mime type of original stored document

  def short_mime_type
    Page::PAGE_MIME_TYPES[self.mime_type]
  end



  ### if an original as JPG already exists and this is called a second time, the PDF will be stored
  def save_file(file_path,file_type)

    path = file_path.tempfile

    FileUtils.cp path, self.path(file_type)
    FileUtils.chmod "go=rr", self.path(file_type)
  end


  #### updates files system with conversion results and updates database status
  def update_conversion(result_jpg, result_sjpg, result_orginal, result_txt)

    self.save_file(result_sjpg, :s_jpg) unless result_sjpg.nil? # small preview pic
    self.save_file(result_jpg, :jpg) unless result_jpg.nil? # medium preview pic
    self.save_file(result_orginal, :org) unless result_orginal.nil?

    self.status=Page::UPLOADED_PROCESSED

    ### pages scanned as JPG are converted to PDF
    if self.short_mime_type==:JPG then
     self.mime_type=PAGE_DEFAULT_SCAN_MIME_TYPE
    end

    if result_sjpg.nil? then
      self.preview= Page::PAGE_NO_PREVIEW
    else
      self.preview= Page::PAGE_PREVIEW
    end

    self.content=result_txt

    self.save!

  end

  private

  def CleanPositionsOnRemove(document_id, position)
    Page.update_all("position = position -1", "document_id = #{document_id} and position > #{position}")
  end


end


