class UploadedFile < ApplicationRecord
  has_attached_file :actual_file

#  validates_attachment_content_type :actual_file, content_type: {content_type: ['image/jpeg', 'image/gif', 'image/png',
#                                                     'text/plain',
#                                                     'text/rtf',
#                                                     'application/pdf',
#                                                     'application/msword'] }

  validates_attachment :actual_file, presence: true,
                       content_type: { content_type: ['image/jpeg', 'image/gif', 'image/png',
                                                     'text/plain',
                                                     'text/rtf',
                                                     'application/pdf',
                                                     'application/msword'] }
end
