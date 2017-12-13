Feature: Visitor sets number of companies to show (pagination for 'all companies' view)

  As a visitor,
  so that I can view the list of companies in a way that suits me and my device,
  I want to be able to control how many companies are shown on a page. (pagination)


  Note that the interaction with the 'show/hide search form' UI item and the
  pagination select list ('items_count') can be very delicate when running the tests
  via Capybara.  Thus the order of the items clicked and selected in the scenarios below
  is important:
    - the 'show/hide search form' must be hidden, else the list of companies contained in
      one of the search fields sometimes show up as false-positives (e.g. when a company
      should _not_ be visible, it is reported as visible if the search field for
      company names is visible)
    - must first select the pagniation select list ('items_count') by doing a
      Then I select "10" in select list "items_count" step.  Then you can 'really'
      select the number of items you want ( = you can really select the option
      you're interested in for that select list)
      This seems related to the previous interactions in the scenario.  It seems that
      this is required due to some combination of states and events that the
      browser + page are in.



  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name     |
      | Alingsås |
      | Bromölla |

    Given the following companies exist:
      | name      | company_number | email                  | region       | kommun   |
      | Company01 | 5560360793     | snarky@snarkybarky.com | Stockholm    | Alingsås |
      | Company02 | 2120000142     | bowwow@bowsersy.com    | Västerbotten | Bromölla |
      | Company03 | 6613265393     | cmpy3@mail.com         | Stockholm    | Alingsås |
      | Company04 | 6222279082     | cmpy4@mail.com         | Stockholm    | Alingsås |
      | Company05 | 8025085252     | cmpy5@mail.com         | Stockholm    | Alingsås |
      | Company06 | 6914762726     | cmpy6@mail.com         | Stockholm    | Alingsås |
      | Company07 | 7661057765     | cmpy7@mail.com         | Stockholm    | Alingsås |
      | Company08 | 7736362901     | cmpy8@mail.com         | Stockholm    | Alingsås |
      | Company09 | 6112107039     | cmpy9@mail.com         | Stockholm    | Alingsås |
      | Company10 | 3609340140     | cmpy10@mail.com        | Stockholm    | Alingsås |
      | Company11 | 2965790286     | cmpy11@mail.com        | Stockholm    | Alingsås |
      | Company12 | 4268582063     | cmpy12@mail.com        | Stockholm    | Alingsås |
      | Company13 | 8028973322     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company14 | 8356502446     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company15 | 8394317054     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company16 | 8423893877     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company17 | 8589182768     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company18 | 8616006592     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company19 | 8764985894     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company20 | 8822107739     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company21 | 8853655168     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company22 | 8909248752     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company23 | 9074668568     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company24 | 9243957975     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company25 | 9267816362     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company26 | 9360289459     | cmpy13@mail.com        | Stockholm    | Alingsås |
      | Company27 | 9475077674     | cmpy13@mail.com        | Stockholm    | Alingsås |

    And the following users exists
      | email        | admin |
      | a@mutts.com  |       |
      | admin@shf.se | true  |

    And the following payments exist
      | user_email  | start_date | expire_date | payment_type | status | hips_id | company_number |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6613265393     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6222279082     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8025085252     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6914762726     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7661057765     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7736362901     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6112107039     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 3609340140     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2965790286     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 4268582063     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8028973322     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8356502446     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8394317054     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8423893877     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8589182768     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8616006592     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8764985894     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8822107739     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8853655168     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8909248752     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9074668568     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9243957975     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9267816362     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9360289459     |
      | a@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 9475077674     |


  @selenium @time_adjust
  Scenario: default number shown is 10
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("activerecord.attributes.company.name") link
    And I click on t("toggle.company_search_form.hide")
    And I should see "Company02"
    And I should not see "2120000142"
    And I should see "Company01"
    And I should not see "5560360793"
    And I should see "Company10"
    And I should not see "3609340140"
    And I should not see "Company11"
    Then I click on t("will_paginate.next_label") link
    And I should see "Company11"
    And I should not see "Company10"


  @selenium @time_adjust
  Scenario: view 10 companies; ensure the company name is not shown if it is > items_count selected to show
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And I click on t("activerecord.attributes.company.name") link
    Then I select "10" in select list "items_count"
    And I wait for all ajax requests to complete
    And "items_count" should have "10" selected
    And I should see "Company01"
    And I should see "Company02"
    And I should see "Company03"
    And I should see "Company04"
    And I should see "Company05"
    And I should see "Company06"
    And I should see "Company07"
    And I should see "Company08"
    And I should see "Company09"
    And I should see "Company10"
    And I should not see "Company11"
    And I should not see "Company12"
    And I should not see "Company13"
    And I should not see "Company14"
    And I should not see "Company15"
    And I should not see "Company16"
    And I should not see "Company17"
    And I should not see "Company18"
    And I should not see "Company19"
    And I should not see "Company20"
    And I should not see "Company21"
    And I should not see "Company22"
    And I should not see "Company23"
    And I should not see "Company24"
    And I should not see "Company25"
    And I should not see "Company26"


  @selenium @time_adjust
  Scenario: view 25 companies; ensure the company name is not shown if it is > items_count selected to show
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And I click on t("activerecord.attributes.company.name") link
    Then I select "10" in select list "items_count"
    Then I select "25" in select list "items_count"
    And I wait for all ajax requests to complete
    And "items_count" should have "25" selected
    And I should see "Company01"
    And I should see "Company02"
    And I should see "Company03"
    And I should see "Company04"
    And I should see "Company05"
    And I should see "Company06"
    And I should see "Company07"
    And I should see "Company08"
    And I should see "Company09"
    And I should see "Company10"
    And I should see "Company11"
    And I should see "Company12"
    And I should see "Company13"
    And I should see "Company14"
    And I should see "Company15"
    And I should see "Company16"
    And I should see "Company17"
    And I should see "Company18"
    And I should see "Company19"
    And I should see "Company20"
    And I should see "Company21"
    And I should see "Company22"
    And I should see "Company23"
    And I should see "Company24"
    And I should see "Company25"
    And I should not see "Company26"


  @selenium @time_adjust
  Scenario: view all companies
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And I click on t("activerecord.attributes.company.name") link
    Then I select "10" in select list "items_count"
    Then I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "27" companies
    And "items_count" should have "All" selected
    And I should see "Company01"
    And I should see "Company02"
    And I should see "Company03"
    And I should see "Company04"
    And I should see "Company05"
    And I should see "Company06"
    And I should see "Company07"
    And I should see "Company08"
    And I should see "Company09"
    And I should see "Company10"
    And I should see "Company11"
    And I should see "Company12"
    And I should see "Company13"
    And I should see "Company14"
    And I should see "Company15"
    And I should see "Company16"
    And I should see "Company17"
    And I should see "Company18"
    And I should see "Company19"
    And I should see "Company20"
    And I should see "Company21"
    And I should see "Company22"
    And I should see "Company23"
    And I should see "Company24"
    And I should see "Company25"
    And I should see "Company26"
    And I should see "Company27"


  @selenium @time_adjust
  Scenario: Pagination: Change number of items multiple times
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And I click on t("activerecord.attributes.company.name") link
    And "items_count" should have "10" selected
    And I should see "10" companies
    And I should see "Company10"
    And I should not see "Company11"
    And I should not see "Company26"
    Then I select "25" in select list "items_count"
    And I wait for all ajax requests to complete
    And "items_count" should have "25" selected
    Then I should see "25" companies
    And I should see "Company01"
    And I should see "Company02"
    And I should see "Company03"
    And I should see "Company04"
    And I should see "Company05"
    And I should see "Company06"
    And I should see "Company07"
    And I should see "Company08"
    And I should see "Company09"
    And I should see "Company10"
    And I should see "Company11"
    And I should see "Company12"
    And I should see "Company13"
    And I should see "Company14"
    And I should see "Company15"
    And I should see "Company16"
    And I should see "Company17"
    And I should see "Company18"
    And I should see "Company19"
    And I should see "Company20"
    And I should see "Company21"
    And I should see "Company22"
    And I should see "Company23"
    And I should see "Company24"
    And I should see "Company25"
    And I should not see "9360289459"
    Then I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "27" companies
    And I should see "Company26"
    And I should see "Company27"
