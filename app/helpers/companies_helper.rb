module CompaniesHelper

  def last_category_name company
    company.business_categories.any? ? company.business_categories.last.name : ''
  end


  def list_categories company, separator=' '
    if company.business_categories.any?
      company.business_categories.order(:name).map(&:name).join(separator)
    end
  end

  # html to display for a company when showing a marker on a map
  def marker_text company
    text = "<div id='company-map-marker'>"
      text << "<p class='name'>#{company.name}</p>"
      text << "<p class='categories'>#{list_categories company, ', '}</p>"
      text << "<br>"
    company.addresses.each do | addr |
      text << "<p class='entire-address'>#{addr.entire_address}</p>"
    end

    text << "</div>"

    text
  end
end
