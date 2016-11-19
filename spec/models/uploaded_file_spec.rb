require 'rails_helper'

RSpec.describe UploadedFile, type: :model do

  describe "accepted content types" do
    it "png" do
      expect(build(:uploaded_file, :png)).to be_valid
    end
    it "gif" do
      expect(build(:uploaded_file, :gif)).to be_valid
    end
    it "jpg" do
      expect(build(:uploaded_file, :jpg)).to be_valid
    end

    it "pdf" do
      expect(build(:uploaded_file, :pdf)).to be_valid
    end
    it "txt" do
      expect(build(:uploaded_file, :txt)).to be_valid
    end

  end

  describe "unacceptable contented types" do

    it "binary" do
      expect(build(:uploaded_file, :bin)).not_to be_valid
    end

    it ".exe" do
      expect(build(:uploaded_file, :exe)).not_to be_valid
    end


  end

end
