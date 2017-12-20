RSpec.shared_examples 'it gracefully handles bad search parameters' do |test_description, bad_parameters, expected_redirect, plural_search_items|

  it "#{test_description} (redirects and flashes an alert)" do

    get :index, params: bad_parameters

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(expected_redirect)

    expected_flash = I18n.t('errors.bad_search_params', search_item: plural_search_items)
    expect(flash[:alert]).to include(expected_flash), "expected flash[:alert] to include '#{expected_flash}' but it didn't. flash[:alert] = #{flash[:alert]}."

  end


end
