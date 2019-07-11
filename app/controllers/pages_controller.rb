class PagesController < ApplicationController
  include HighVoltage::StaticPage

  before_action :authorize_page, only: [:update, :show, :edit]

  NO_AUTH_NEEDED_PAGES = ['cookies']

  private

  def authorize_page
    no_auth_needed(params.dig(:id)) ? true : authorize(:page)
  end


  def no_auth_needed(page_id)
    NO_AUTH_NEEDED_PAGES.include? page_id
  end
end
