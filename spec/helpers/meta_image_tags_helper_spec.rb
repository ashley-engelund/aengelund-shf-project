require 'rails_helper'
require 'shared_context/mock_app_configuration'


RSpec.describe MetaImageTagsHelper, type: :helper do

  STORAGE_PATH     = File.join(Rails.public_path, 'storage', 'test')
  DEFAULT_IMG_FN   = 'default_image_filename.png'
  IMG_PATH         = File.join(STORAGE_PATH, DEFAULT_IMG_FN)


  before(:all) do
    @storage_test_path = STORAGE_PATH

    @delete_storage_path_when_done = false # default

    unless File.exist?(@storage_test_path)
      @delete_storage_path_when_done = true
      FileUtils.mkdir_p @storage_test_path
    end

    FileUtils.copy_file(file_fixture('image.png'), File.join(@storage_test_path, DEFAULT_IMG_FN))
  end


  after(:all) do
    FileUtils.rm(File.join(@storage_test_path, DEFAULT_IMG_FN))
    FileUtils.rmdir(@storage_test_path) if  @delete_storage_path_when_done
  end


  describe 'page_meta_image_tags' do

    describe 'the attachment' do

      context 'does not respond to :path' do

        it 'uses the Site defaults' do
          expect(helper).to receive(:use_site_defaults)
          helper.page_meta_image_tags(nil)
        end

      end

      context 'does respond to :path' do

        context 'does not respond to :url' do

          it 'uses the Site defaults' do
            expect(helper).to receive(:use_site_defaults)
            helper.page_meta_image_tags(FauxPath)
          end

        end

        context 'does respond to :url' do

          context 'attachment exists' do

            it 'uses given attachment' do

              mock_attachment = MockAttachmentForFile.new(IMG_PATH)

              expect(helper).to receive(:meta_image_tags)
                                    .with(IMG_PATH,
                                          'png',
                                          width:  80,
                                          height: 80).and_call_original

              helper.page_meta_image_tags(mock_attachment)
            end

          end


          context 'attachment does not exist' do

            it 'uses the site defaults' do
              expect(helper).to receive(:use_site_defaults)
              helper.page_meta_image_tags('blorf')
            end

          end


        end

      end

    end


    it 'if no image filename is given it uses default' do
      expect(helper).to receive(:use_site_defaults)
      helper.page_meta_image_tags(nil)
    end

  end


  describe 'use_site_defaults' do

    it 'gets the meta image info from SiteMetaInfoDefaults' do

      expect(SiteMetaInfoDefaults).to receive(:image_public_url).and_return(FauxUrl.url)
      expect(SiteMetaInfoDefaults).to receive(:image_type).and_return('jpg')
      expect(SiteMetaInfoDefaults).to receive(:image_width).and_return(100)
      expect(SiteMetaInfoDefaults).to receive(:image_height).and_return(200)

      expect(helper).to receive(:meta_image_tags).with(FauxUrl.url, 'jpg', width: 100, height: 200)

      helper.use_site_defaults
    end

  end


  describe 'meta_image_tags(image_filename, image_type, width: 0, height: 0)' do

    it 'returns a hash with  image_src: and og:image, og:image:width, height, type' do

      expect(helper.meta_image_tags(FauxUrl.url, 'blorf', width: 80, height: 80))
          .to match({ image_src: FauxUrl.url,
                      og:        {
                          image: {
                              _:      FauxUrl.url,
                              width:  80,
                              height: 80,
                              type:   'image/blorf'
                          }
                      }
                    })
    end

    it 'default image width = 0 if not specified' do
      expect(helper.meta_image_tags(FauxUrl.url, 'png', height: 80))
          .to eq({ image_src: FauxUrl.url,
                   og:        {
                       image: {
                           _:      FauxUrl.url,
                           width:  0,
                           height: 80,
                           type:   'image/png'
                       }
                   }
                 })
    end

    it 'default image height is 0 if not specified' do
      expect(helper.meta_image_tags(FauxUrl.url, 'png', width: 80))
          .to eq({ image_src: FauxUrl.url,
                   og:        {
                       image: {
                           _:      FauxUrl.url,
                           width:  80,
                           height: 0,
                           type:   'image/png'
                       }
                   }
                 })
    end

  end

end
