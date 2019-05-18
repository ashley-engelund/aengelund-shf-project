require 'rails_helper'
require 'shared_context/mock_app_configuration'


class PageMetaTagsSetterTestController < ApplicationController
  include PageMetaTagsSetter
end


RSpec.describe PageMetaTagsSetterTestController, type: :controller do


  MOCK_BASE_URL   = 'http://test.host' unless defined?(MOCK_BASE_URL)
  MOCK_REQ_PATH   = '/test-path' unless defined?(MOCK_REQ_PATH)
  MOCK_ASSET_PATH = '/assets' unless defined?(MOCK_ASSET_PATH)

  let(:expected_base_url) { "#{MOCK_BASE_URL}#{MOCK_ASSET_PATH}/" }

  let(:default_title)  { SiteMetaInfoDefaults.title }
  let(:default_full_title) { "#{SiteMetaInfoDefaults.title} | #{SiteMetaInfoDefaults.site_name}" }
  let(:default_desc) { SiteMetaInfoDefaults.description }
  let(:default_keywords) { SiteMetaInfoDefaults.keywords }
  let(:default_image_filename) { SiteMetaInfoDefaults.image_filename }
  let(:default_image_url) { "http://test.host/assets/#{default_image_filename}" }
  let(:default_image_width) { SiteMetaInfoDefaults.image_width }
  let(:default_image_height) { SiteMetaInfoDefaults.image_height }
  let(:default_image_type) { "image/#{SiteMetaInfoDefaults.image_type}" }


  before(:all) do
    @orig_locale = I18n.locale

    @meta_setter = PageMetaTagsSetterTestController.new
    @meta_setter.set_request! ActionDispatch::TestRequest.create
    @meta_setter.request.path = MOCK_REQ_PATH

  end

  after(:all) { I18n.locale = @orig_locale }


  describe 'set_meta_tags_for_url_path' do

    describe 'uses defaults if entries are not in the locale file' do

      def set_the_meta_tags
        @meta_setter.set_meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)

        # have to check results like this since the method calls set_meta_tags twice
        # and thus we could only check the second call with .to receive...
        @meta_tags_set = @meta_setter.send(:meta_tags).send(:meta_tags)
      end


      it 'default title = SiteMetaInfoDefaults.title |  SiteMetaInfoDefaults.site ' do
        allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

        set_the_meta_tags
        expect(@meta_tags_set['title']).to eq default_title
      end

      it 'default description = SiteMetaInfoDefaults.description' do
        allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

        set_the_meta_tags
        expect(@meta_tags_set['description']).to eq default_desc
      end

      it "default keywords = SiteMetaInfoDefaults.keywords" do
        allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

        set_the_meta_tags
        expect(@meta_tags_set['keywords']).to eq SiteMetaInfoDefaults.keywords
      end


      describe 'Facebook OpenGraph (og)' do

        it 'title = default title' do
          allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

          set_the_meta_tags
          expect(@meta_tags_set['og']['title']).to eq default_full_title
        end

        it 'description = default description' do
          allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

          set_the_meta_tags
          expect(@meta_tags_set['og']['description']).to eq default_desc
        end

        it 'type = website' do
          allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

          set_the_meta_tags
          expect(@meta_tags_set['og']['type']).to eq 'website'
        end

        it 'url = http://test.host/test-path' do        allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

        set_the_meta_tags
          expect(@meta_tags_set['og']['url']).to eq 'http://test.host/test-path'
        end


        describe 'locale is the I18n.locale plus country string' do

          it "locale :sv = 'sv_SE'" do
            I18n.locale = :sv
            allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

            #set_the_meta_tags
            subject.set_meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)

            expect(subject.send(:meta_tags)
                       .send(:meta_tags)[:og][:locale]).to eq("sv_SE")
          end

          it "locale :en = 'en_US'" do
            I18n.locale = :en
            allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

            subject.set_meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)

            expect(subject.send(:meta_tags)
                       .send(:meta_tags)[:og][:locale]).to eq("en_US")
          end
        end

      end


    end


    it 'appends Business Categories to list of keywords' do
      allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

      create(:business_category, name: 'category1')
      create(:business_category, name: 'category2')

      subject.set_meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)

      expect(subject.send(:meta_tags)
                 .send(:meta_tags)[:keywords]).to eq("#{default_keywords}, category1, category2")
    end


    it 'gets info from locale file' do

      I18n.locale = :sv
      allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(MockAppConfig)

      # see https://github.com/rspec/rspec-mocks/issues/663 for more info on why
      # you cannot just stub I18n.t()

      # will return 'blorf' when it pretends (mocks) to look up something in a locale file
      allow(I18n.config.backend).to receive(:translate)
                                        .with(anything, anything, anything)
                                        .and_return('blorf')

      allow(SiteMetaInfoDefaults).to receive(:facebook_app_id)
                                          .and_return(12345678909876)
      expected_result = {
          "site"        => 'site name',
          "title"       => 'site title',
          "description" => 'site meta description',
          "keywords"    => 'blorf',
          "og"          => {
              "site_name"   => "site name",
              "title"       => 'site title | site name',
              "description" => 'site meta description',
              "url"         => 'http://test.host/test-path',
              "type"        => 'blorf',
              "locale"      => 'sv_SE',
          },
          "fb" => {
            "app_id" => 12345678909876
          },
          "twitter"     => {
              "card" => 'blorf'
          },
      }

      subject.set_meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)

      expect(subject.send(:meta_tags)
                 .send(:meta_tags)).to eq expected_result
    end

  end


  describe 'set_facebook_meta_tags' do

    it 'sets fb:app_id with the default value' do
      @meta_setter.set_facebook_meta_tags
      meta_tags_set = @meta_setter.send(:meta_tags)

      expect(meta_tags_set['fb']['app_id']).to eq SiteMetaInfoDefaults.facebook_app_id
    end

    it 'can specify the app_id' do
      @meta_setter.set_facebook_meta_tags(app_id: 987654321)
      meta_tags_set = @meta_setter.send(:meta_tags)

      expect(meta_tags_set['fb']['app_id']).to eq 987654321
    end

  end

  describe 'set_twitter_meta_tags' do

    it 'default: card = SiteMetaInfoDefaults.twitter_card_type' do
      @meta_setter.set_twitter_meta_tags
      meta_tags_set = @meta_setter.send(:meta_tags)

      expect(meta_tags_set['twitter']['card']).to eq SiteMetaInfoDefaults.twitter_card_type
    end

    it "card = I18n.t('meta.twitter.card')" do
      @meta_setter.set_twitter_meta_tags(card: 'blorf')
      meta_tags_set = @meta_setter.send(:meta_tags)

      expect(meta_tags_set['twitter']['card']).to eq 'blorf'
    end
  end


  describe 'set_page_meta_robots_none' do

    it 'uses set_meta_tags to set nofollow and noindex to true' do

      expect(subject).to receive(:set_meta_tags)
                             .with({ nofollow: true, noindex: true })

      subject.set_page_meta_robots_none

    end
  end


end
