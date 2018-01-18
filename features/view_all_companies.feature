Feature: Visitor can see and search through companies to find ones that could be helpful.

  As a visitor,
  so that I can find companies that can offer me services,
  I want to see all companies


  Hints and Reminders about Scenarios that should be covered for pages/views:
  ---------------------------------------------------------------------------
  Remember that this file should describe what the feature should accomplish,
  including what the user should and should not see,
  in addition to testing for correctness and some boundary conditions (SAD PATHS).

  Scenarios:
  - Authorization: What is expected for each role?
      Who can see the page?  Which roles (Admin | Member | User | Visitor) can and cannot see the page?

  - Exactly what information should and should not be seen on the page?
    What are all of the elements that they should be able to see?
    Especially test things that are different between roles.
      For example, if an Admin should see a different page title,
      be sure to include a scenario (or scenarios)
      that makes that clear and tests for that.

  - What are the different states of the data that would affect the what someone using the system
  would see or do for this particular feature?

  - Pagination: If appropriate, test the different pagination selection options,
    including any default selection.

  - Default state:  What should the default state for any options be? (searching, sorting, pagination, etc.)
  ------------

  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |
      | Uppsala      |

    Given the following kommuns exist:
      | name     |
      | Alingsås |
      | Bromölla |
      | Alvesta  |
      | Aneby    |

    And the following business categories exist
      | name    |
      | Groomer |

    Given the following companies exist:
      | name      | company_number | email           | region       | kommun   |
      | Company01 | 5560360793     | cmpy1@mail.com  | Stockholm    | Alingsås |
      | Company02 | 2120000142     | cmpy2@mail.com  | Västerbotten | Bromölla |
      | Company03 | 6613265393     | cmpy3@mail.com  | Stockholm    | Alingsås |
      | Company04 | 6222279082     | cmpy4@mail.com  | Stockholm    | Alingsås |
      | Company05 | 8025085252     | cmpy5@mail.com  | Stockholm    | Alingsås |
      | Company06 | 6914762726     | cmpy6@mail.com  | Stockholm    | Alingsås |
      | Company07 | 7661057765     | cmpy7@mail.com  | Stockholm    | Alingsås |
      | Company08 | 7736362901     | cmpy8@mail.com  | Stockholm    | Alingsås |
      | Company09 | 6112107039     | cmpy9@mail.com  | Stockholm    | Alingsås |
      | Company10 | 3609340140     | cmpy10@mail.com | Stockholm    | Alingsås |
      | Company11 | 2965790286     | cmpy11@mail.com | Stockholm    | Alingsås |
      | Company12 | 4268582063     | cmpy12@mail.com | Stockholm    | Alingsås |
      | Company13 | 8028973322     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company14 | 8356502446     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company15 | 8394317054     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company16 | 8423893877     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company17 | 8589182768     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company18 | 8616006592     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company19 | 8764985894     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company20 | 8822107739     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company21 | 5569767808     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company22 | 8909248752     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company23 | 9074668568     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company24 | 9243957975     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company25 | 9267816362     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company26 | 9360289459     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company27 | 9475077674     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company28 | 8728875504     | cmpy13@mail.com | Stockholm    | Alingsås |
      | Company29 | 5872150379     | cmpy13@mail.com | Stockholm    | Alingsås |

    And the following company addresses exist:
      | company_name | region     | kommun  |
      | Company02    | Norrbotten | Alvesta |
      | Company02    | Uppsala    | Aneby   |

    And the following users exists
      | email            | admin | member |
      | member@mutts.com |       | true   |
      | user@mutts.com   |       | false  |
      | admin@shf.se     | true  |        |

    And the following payments exist
      | user_email       | start_date | expire_date | payment_type | status | hips_id | company_name |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company01    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company02    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company03    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company04    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company05    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company06    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company07    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company08    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company09    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company10    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company11    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company12    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company13    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company14    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company15    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company16    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company17    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company18    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company19    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company20    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company21    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company22    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company23    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company24    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company25    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company26    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company27    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    | Company28    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company01    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company02    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company03    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company04    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company05    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company06    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company07    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company08    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company09    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company10    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company11    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company12    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company13    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company14    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company15    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company16    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company17    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company18    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company19    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company20    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company21    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company22    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company23    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company24    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company25    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company26    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company27    |
      | member@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company28    |

    And the following applications exist:
      | user_email       | company_name | state    | categories |
      | member@mutts.com | Company01    | accepted | Groomer    |
      | member@mutts.com | Company02    | accepted | Groomer    |
      | member@mutts.com | Company03    | accepted | Groomer    |
      | member@mutts.com | Company04    | accepted | Groomer    |
      | member@mutts.com | Company05    | accepted | Groomer    |
      | member@mutts.com | Company06    | accepted | Groomer    |
      | member@mutts.com | Company07    | accepted | Groomer    |
      | member@mutts.com | Company08    | accepted | Groomer    |
      | member@mutts.com | Company09    | accepted | Groomer    |
      | member@mutts.com | Company10    | accepted | Groomer    |
      | member@mutts.com | Company11    | accepted | Groomer    |
      | member@mutts.com | Company12    | accepted | Groomer    |
      | member@mutts.com | Company13    | accepted | Groomer    |
      | member@mutts.com | Company14    | accepted | Groomer    |
      | member@mutts.com | Company15    | accepted | Groomer    |
      | member@mutts.com | Company16    | accepted | Groomer    |
      | member@mutts.com | Company17    | accepted | Groomer    |
      | member@mutts.com | Company18    | accepted | Groomer    |
      | member@mutts.com | Company19    | accepted | Groomer    |
      | member@mutts.com | Company20    | accepted | Groomer    |
      | member@mutts.com | Company21    | accepted | Groomer    |
      | member@mutts.com | Company22    | accepted | Groomer    |
      | member@mutts.com | Company23    | accepted | Groomer    |
      | member@mutts.com | Company24    | accepted | Groomer    |
      | member@mutts.com | Company25    | accepted | Groomer    |
      | member@mutts.com | Company26    | accepted | Groomer    |
      | member@mutts.com | Company27    | accepted | Groomer    |
      | user@mutts.com   | Company28    | accepted | Groomer    |
      | member@mutts.com | Company29    | accepted | Groomer    |

  @selenium @time_adjust
  Scenario: Visitor sees all companies and OrgNr is not shown
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    And I hide the search form
    Then I should see t("companies.index.h_companies_listed_below")
    # make sure the list is sorted so we know what to expect
    And I click on t("activerecord.attributes.company.name")
    And I should see "Company02"
    And I should not see "2120000142"
    And I should see "Company01"
    And I should not see "5560360793"
    And I should not see t("companies.new_company")

  @selenium @time_adjust
  Scenario: Visitor sees multiple regions and kommuns for a company in the companies list
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I hide the search form
    # make sure the list is sorted so we know what to expect
    And I click on t("activerecord.attributes.company.name")
    And I should see "Company02"
    And I should see "Västerbotten" in the row for "Company02"
    And I should see "Norrbotten" in the row for "Company02"
    And I should see "Uppsala" in the row for "Company02"
    And I should see "Bromölla" in the row for "Company02"
    And I should see "Alvesta" in the row for "Company02"
    And I should see "Aneby" in the row for "Company02"
    And I should not see "Stockholm" in the row for "Company02"

  @time_adjust @selenium
  Scenario: User sees all the companies and OrgNr is not shown
    Given the date is set to "2017-10-01"
    Given I am logged in as "user@mutts.com"
    And I am on the "all companies" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I hide the search form
    # make sure the list is sorted so we know what to expect
    And I click on t("activerecord.attributes.company.name")
    And I should see "Company02"
    And I should not see "2120000142"
    And I should see "Company01"
    And I should not see "5560360793"
    And I should not see t("companies.new_company")


  @time_adjust @selenium
  Scenario: Member sees all the companies and OrgNr is not shown
    Given the date is set to "2017-10-01"
    Given I am logged in as "member@mutts.com"
    And I am on the "all companies" page
    #And I wait for all ajax requests to complete
    Then I should see t("companies.index.h_companies_listed_below")
    And I hide the search form
    # make sure the list is sorted so we know what to expect
    And I click on t("activerecord.attributes.company.name")
    And I should see "Company02"
    And I should not see "2120000142"
    And I should see "Company01"
    And I should not see "5560360793"
    And I should not see t("companies.new_company")


  @selenium @time_adjust
  Scenario: Pagination
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    # make sure the list is sorted so we know what to expect
    And I click on t("activerecord.attributes.company.name")
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
  Scenario: I18n translations
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I set the locale to "sv"
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    Then I click on t("toggle.company_search_form.hide") button
    And I should see "Verksamhetslän"
    And I should see "Kategori"
    And I should not see "Region"
    And I should not see "Category"
    Then I click on "change-lang-to-english"
    And I set the locale to "en"
    Then I click on t("toggle.company_search_form.hide") button
    And I wait 1 second
    And I should see "Region"
    And I should see "Category"
    And I should not see "Verksamhetslän"
    And I should not see "Kategori"

  @selenium @time_adjust
  Scenario: Pagination: Set number of items per page
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And "items_count" should have "10" selected
    And I should see "10" companies
    # make sure the list is sorted so we know what to expect
    And I click on t("activerecord.attributes.company.name")
    And I should see "Company10"
    And I should not see "Company11"
    And I should not see "Company26"
    Then I select "25" in select list "items_count"
    And I wait for all ajax requests to complete
    Then I should see "25" companies
    And "items_count" should have "25" selected
    And I should see "Company01"
    And I should see "Company02"
    And I should see "Company11"
    And I should see "Company12"
    And I should see "Company24"
    And I should see "Company25"
    And I should not see "Company26"

  @selenium @time_adjust
  Scenario: Companies lacking branding payment or members not shown
    Given the date is set to "2017-10-01"
    Given I am Logged out
    And I am on the "landing" page
    Then I should see t("companies.index.h_companies_listed_below")
    And I click on t("toggle.company_search_form.hide")
    And "items_count" should have "10" selected
    Then I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    And I scroll to the top
    # make sure the list is sorted so we know what to expect
    And I click on t("activerecord.attributes.company.name")
    And I should see "27" companies
    And I should see "Company10"
    And I should see "Company27"
    And I should not see "Company28"
    And I should not see "Company29"

  @selenium @time_adjust
  Scenario: Admin can see all companies even if lacking branding payment or members
    Given the date is set to "2017-10-01"
    And I am logged in as "admin@shf.se"
    And I am on the "all companies" page
    And "items_count" should have "10" selected
    Then I select "All" in select list "items_count"
    And I wait for all ajax requests to complete
    And I scroll to the top
    And I should see "29" companies
    And I should see "Company10"
    And I should see "Company27"
    And I should see "Company28"
    And I should see "Company29"

  @selenium @time_adjust
  Scenario: Page titles are correct for each role (Admin sees a different title than anyone else)
    Given the date is set to "2017-10-01"
    And I am logged in as "admin@shf.se"
    And I am on the "all companies" page
    Then I should see case insensitive t("companies.index.admin_title")
    And I am logged out
    And I am on the "all companies" page
    Then I should see case insensitive t("companies.index.title")
    And I am logged in as "user@mutts.com"
    And I am on the "all companies" page
    Then I should see case insensitive t("companies.index.title")
    And I am logged in as "member@mutts.com"
    And I am on the "all companies" page
    Then I should see case insensitive t("companies.index.title")


