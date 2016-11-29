class UploadedFile < ApplicationRecord

  belongs_to :membership_application

  has_attached_file :actual_file

  validates_attachment :actual_file, content_type: { content_type: ['image/jpeg', 'image/gif', 'image/png',
                                                     'text/plain',
                                                     'text/rtf',
                                                     'application/pdf',
                                                     'application/msword'],
                                       message: 'Sorry, this is not a file type you can upload.'}
end
