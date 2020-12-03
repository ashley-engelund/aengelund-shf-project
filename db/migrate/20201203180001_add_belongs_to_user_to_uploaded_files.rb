class AddBelongsToUserToUploadedFiles < ActiveRecord::Migration[5.2]

  def change
    add_reference :uploaded_files, :user, index: true, foreign_key: true

    UploadedFile.counter_culture_fix_counts
  end
end
