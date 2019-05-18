require 'rails_helper'
require 'shared_context/mock_app_configuration'


RSpec.describe SiteMetaInfoDefaults do

  include_context 'mock AppConfiguration'

  subject { SiteMetaInfoDefaults }


  it "site_name is from the AppConfiguration" do
    expect(MockAppConfig).to receive(:site_name).and_call_original
    expect(subject.site_name).to eq 'site name'
  end

  it "title is from the AppConfiguration" do
    expect(MockAppConfig).to receive(:site_meta_title).and_call_original
    expect(subject.title).to eq 'site title'
  end

  it "description from the AppConfiguration" do
    expect(MockAppConfig).to receive(:site_meta_description).and_call_original
    expect(subject.description).to eq 'site meta description'
  end

  it "keywords are the AppConfiguration site_meta_keywords" do
    expect(MockAppConfig).to receive(:site_meta_keywords).and_call_original
    expect(subject.keywords).to eq 'site meta keywords'
  end


  it "image_filename is the path to the AppConfiguration site_meta_image file name (relative to Rails.root)" do
    expect(MockAppConfig).to receive(:site_meta_image).twice.and_call_original
    expect(subject.image_filename).to eq FauxPath.path
  end

  it 'image_public_url is the full url to the AppConfiguration site_meta_image (includes https: and the site name)' do
    expect(mock_app_config).to receive(:site_meta_image).twice.and_call_original
    expect(subject.image_public_url).to match(/https:\/\/hitta\.sverigeshundforetagare\.se\/public\/storage\/path\/to\/the\/image_filename\.jpg/)
  end

  it "image_type is the end of AppConfiguration site_meta_image file type (does not include 'image/')" do

    expect(mock_app_config).to receive(:site_meta_image_content_type).twice
                                   .and_call_original

    default_image_type = subject.image_type
    expect(default_image_type).not_to eq 'image/blorf'
    expect(default_image_type).to eq(MockAppConfig.site_meta_image_content_type.split('/').last)
    expect(default_image_type).not_to match(/image\//)
  end

  it 'image_width is the AppConfiguration site_meta_image width' do
    expect(mock_app_config).to receive(:site_meta_image_width).and_call_original
    expect(subject.image_width).to eq 80
  end

  it 'image_height is the AppConfiguration site_meta_image height' do
    expect(mock_app_config).to receive(:site_meta_image_height).and_call_original
    expect(subject.image_height).to eq 80
  end

  it "og_type is 'website'" do
    expect(subject.og_type).to eq 'website'
  end


  describe 'Facebook app id' do

    env_key = 'SHF_FB_APPID'

    it "Facebook App id is ENV['#{env_key}']" do

      # stub the value
      RSpec::Mocks.with_temporary_scope do
        # must stub this way so the rest of ENV is preserved
        stub_const('ENV', ENV.to_hash.merge({ env_key => '123321' }))

        expect(subject.facebook_app_id).to eq(123321)

      end
    end


    it "is 0 if ENV['#{env_key}'] does not exist" do

      # stub the value
      RSpec::Mocks.with_temporary_scope do
        orig_id = ENV.fetch(env_key, nil)

        # must stub this way so the rest of ENV is preserved
        stub_const('ENV', ENV.to_hash)
        ENV.delete(env_key)

        expect(subject.facebook_app_id).to eq(0)
        ENV[env_key] = orig_id if orig_id
      end
    end

  end


  it "twitter_card_type is 'summary'" do
    expect(subject.twitter_card_type).to eq 'summary'
  end


  describe '.use_default_if_blank' do

    it 'is the value if value is not blank' do
      expect(subject.use_default_if_blank(:blorf, 'this is not blank')).to eq 'this is not blank'
    end

    it 'uses the method if the value is blank' do
      expect(subject).to receive(:site_name).and_return('this is the site name')
      subject.use_default_if_blank(:site_name, '')
    end
  end

end
