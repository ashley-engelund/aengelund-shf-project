require 'rails_helper'


RSpec.describe MetaImageTagsHelper, type: :helper do

  let(:test_host) { 'http://test.host' }
  let(:default_image_filename) { SiteMetaInfoDefaults.image_filename }
  let(:default_image_url) { "#{test_host}/assets/#{default_image_filename}" }

  let(:filename_in_public_assets) { File.join(Rails.public_path, 'assets', 'image.png') }


  before(:all) do
    @orig_locale = I18n.locale
    FileUtils.copy_file(file_fixture('image.png'), File.join(Rails.public_path, 'assets', 'image.png'))
  end

  after(:all) do
    I18n.locale = @orig_locale
    FileUtils.rm(File.join(Rails.public_path, 'assets', 'image.png'))
  end


  describe 'page_meta_image_tags' do

    context 'looks up filename from the locale and gets the characteristics' do

      it 'if image filename is given it uses the filename provided' do

        expect(helper).to receive(:meta_image_tags)
                              .with(filename_in_public_assets,
                                    'png',
                                    width:  80,
                                    height: 80)

        helper.page_meta_image_tags(filename_in_public_assets)
      end


      it 'if filename does not exist it looks up info in the locale or uses default' do
        expect(helper).to receive(:fallback_to_locale_or_default_image)

        helper.page_meta_image_tags('blorf')
      end

      it 'if no image filename is given looks up info in the locale or uses default' do
        expect(helper).to receive(:fallback_to_locale_or_default_image)

        helper.page_meta_image_tags(nil)
      end
    end

  end


  it 'gets fingerprinted filename/url from Sprockets' do

    expect_any_instance_of(Sprockets::Rails::Helper).to receive(:compute_asset_path).and_return('fingerprinted!')

    expect(helper.meta_default_image_tags).to eq({ image_src: 'http://test.host/fingerprinted!',
                                                    og:        {
                                                        image: {
                                                            _:      'http://test.host/fingerprinted!',
                                                            width:  1245,
                                                            height: 620,
                                                            type:   'image/jpeg'
                                                        }
                                                    }
                                                  })
  end


  describe 'fallback_to_locale_or_default_image' do

    describe 'uses image filename from locale only if all information required exists in the locale file' do

      before(:each) do
        allow(I18n.config.backend).to receive(:exists?)
                                          .with(:sv, 'meta.default.image_src')
                                          .and_return(true)
        allow(I18n.config.backend).to receive(:exists?)
                                          .with(:sv, 'meta.default.image_src.filename')
                                          .and_return(true)
        allow(I18n.config.backend).to receive(:exists?)
                                          .with(:sv, 'meta.default.image_src.image_type')
                                          .and_return(true)
        allow(I18n.config.backend).to receive(:exists?)
                                          .with(:sv, 'meta.default.image_src.width')
                                          .and_return(true)
        allow(I18n.config.backend).to receive(:exists?)
                                          .with(:sv, 'meta.default.image_src.height')
                                          .and_return(true)
      end


      it 'all info is in the locale file' do

        expect(helper).to receive(:meta_image_from_locale)
        expect(helper).not_to receive(:meta_default_image_tags)

        helper.fallback_to_locale_or_default_image
      end


      describe 'not all info exists so SiteMetaInfoDefaults is used' do

        it 'main key is missing' do
          allow(I18n.config.backend).to receive(:exists?)
                                            .with(:sv, 'meta.default.image_src')
                                            .and_return(false)

          expect(helper).not_to receive(:meta_image_from_locale)
          expect(helper).to receive(:meta_default_image_tags)

          helper.fallback_to_locale_or_default_image
        end

        it 'filename is missing' do

          allow(I18n.config.backend).to receive(:exists?)
                                            .with(:sv, 'meta.default.image_src.filename')
                                            .and_return(false)

          expect(helper).not_to receive(:meta_image_from_locale)
          expect(helper).to receive(:meta_default_image_tags)

          helper.fallback_to_locale_or_default_image
        end

        it 'image type is missing' do
          allow(I18n.config.backend).to receive(:exists?)
                                            .with(:sv, 'meta.default.image_src.image_type')
                                            .and_return(false)

          expect(helper).not_to receive(:meta_image_from_locale)
          expect(helper).to receive(:meta_default_image_tags)

          helper.fallback_to_locale_or_default_image
        end

        it 'width is missing' do
          allow(I18n.config.backend).to receive(:exists?)
                                            .with(:sv, 'meta.default.image_src.width')
                                            .and_return(false)

          expect(helper).not_to receive(:meta_image_from_locale)
          expect(helper).to receive(:meta_default_image_tags)

          helper.fallback_to_locale_or_default_image
        end

        it 'height is missing' do
          allow(I18n.config.backend).to receive(:exists?)
                                            .with(:sv, 'meta.default.image_src.height')
                                            .and_return(false)

          expect(helper).not_to receive(:meta_image_from_locale)
          expect(helper).to receive(:meta_default_image_tags)

          helper.fallback_to_locale_or_default_image
        end
      end

    end

  end


  it 'meta_image_from_locale reads the info from the locale file' do


    allow(I18n).to receive(:translate)
                       .with('meta.default.image_src.filename', { raise: true })
                       .and_return('locale_image.jpg')
    allow(I18n).to receive(:translate)
                       .with('meta.default.image_src.image_type', { raise: true })
                       .and_return('jpg')
    allow(I18n).to receive(:translate)
                       .with('meta.default.image_src.width', { raise: true })
                       .and_return(300)
    allow(I18n).to receive(:translate)
                       .with('meta.default.image_src.height', { raise: true })
                       .and_return(500)

    expect(helper).to receive(:meta_image_tags).with('locale_image.jpg', 'jpg', width: 300, height: 500)

    helper.meta_image_from_locale
  end


  it 'meta_default_image_tags uses the image info from the SiteMetaInfoDefaults' do

    allow(SiteMetaInfoDefaults).to receive(:image_filename).and_return('faux_image.jpg')
    allow(SiteMetaInfoDefaults).to receive(:image_type).and_return('jpg')
    allow(SiteMetaInfoDefaults).to receive(:image_width).and_return(100)
    allow(SiteMetaInfoDefaults).to receive(:image_height).and_return(200)

    expect(helper).to receive(:meta_image_tags).with('faux_image.jpg', 'jpg', width: 100, height: 200)

    helper.meta_default_image_tags
  end


  describe 'meta_image_tags(image_filename, image_type, width: 0, height: 0)' do

    let(:expected_image_url) {  "#{test_host}/assets/#{default_image_filename}" }

    it 'returns a hash with  image_src: and og:image, og:image:width, height, type' do

      expect(helper.meta_image_tags(expected_image_url, 'png', width: 80, height: 80))
          .to match({ image_src: expected_image_url,
                   og:        {
                       image: {
                           _:      expected_image_url,
                           width:  80,
                           height: 80,
                           type:   'image/png'
                       }
                   }
                 })
    end

    it 'default image width = 0 if not specified' do
      expect(helper.meta_image_tags(expected_image_url, 'png', height: 80))
          .to eq({ image_src: expected_image_url,
                   og:        {
                       image: {
                           _:      expected_image_url,
                           width:  0,
                           height: 80,
                           type:   'image/png'
                       }
                   }
                 })
    end

    it 'default image height = 0 if not specified' do
      expect(helper.meta_image_tags(expected_image_url, 'png', width: 80))
          .to eq({ image_src: expected_image_url,
                   og:        {
                       image: {
                           _:      expected_image_url,
                           width:  80,
                           height: 0,
                           type:   'image/png'
                       }
                   }
                 })
    end

  end

end
