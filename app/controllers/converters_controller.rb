require 'Pusher'

class ConvertersController < ApplicationController
  include Pusher

  ### called from converter, this will trigger the Pusher in view
  def convert_status
    @message=params[:message]
    render('convert_status', :handlers => [:erb], :formats => [:js])
  end


  ### called from converter, when preview images are created
  def convert_upload_jpgs

    page=Page.find(params[:page][:id])
    page.save!

    page.save_file(params[:page][:result_jpg], :jpg)
    page.save_file(params[:page][:result_sjpg], :s_jpg)

    push_app_status ## send status-update to application main page via private_pub gem, fayes,
    push_converted_page(page)

    render :nothing => true

  end

  def convert_upload_pdf

    page=Page.find(params[:page][:id])
    page.content=params[:page][:content]
    page.status=Page::UPLOADED_PROCESSED
    page.mime_type='application/pdf' if page.source==Page::PAGE_SOURCE_SCANNED or page.source==Page::PAGE_SOURCE_MOBILE
    page.ocr=true
    ### check if we have a PDF for the page available, either as org file or created in addition
    if page.mime_type=='application/pdf' or not params[:page][:pdf_data].nil?
      page.pdf_exists=true
    end

    page.save_file(params[:page][:org_data], :org) ##this is pdf in case of scanned, otherwise JPG
    page.save_file(params[:page][:pdf_data], :pdf) unless params[:page][:pdf_data]=="" #if JPG, this is the PDF as extra

    page.save!

    push_app_status ## send status-update to application main page via private_pub gem, fayes,
    push_converted_page(page)

    render :nothing => true

  end
end
