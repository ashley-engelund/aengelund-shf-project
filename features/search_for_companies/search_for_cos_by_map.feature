Feature: Search for Companies with Filters and Map

As someone using the site
In order to find companies that are near me
I want to use the map to view and narrow the list of companies.


Background:
  Given the following users exists
    | email                | admin | member |
    | visitor@ex.com       |       | false  |
    | fred@barkyboys.com   |       | true   |
    | john@happymutts.com  |       | true   |
    | anna@dogsrus.com     |       | true   |
    | emma@weluvdogs.com   |       | true   |
    | admin@shf.se         | true  |        |

  And the following business categories exist
    | name         |
    | Groomer      |
    | Psychologist |
    | Trainer      |
    | Walker       |

  Given the following regions exist:
    | name         |
    | Stockholm    |
    | Västerbotten |
    | Norrbotten   |
    | Sweden       |

  Given the following kommuns exist:
    | name      |
    | Alingsås  |
    | Bromölla  |
    | Laxå      |
    | Östersund |

  And the following companies exist:
    | name        | company_number | email                | region       | kommun    |
    | Barky Boys  | 5560360793     | barky@barkyboys.com  | Stockholm    | Alingsås  |
    | HappyMutts  | 2120000142     | woof@happymutts.com  | Västerbotten | Bromölla  |
    | Dogs R Us   | 5562252998     | chief@dogsrus.com    | Norrbotten   | Östersund |
    | We Luv Dogs | 5569467466     | alpha@weluvdogs.com  | Sweden       | Laxå      |

  And the following payments exist
    | user_email          | start_date | expire_date | payment_type | status | hips_id | company_number |
    | fred@barkyboys.com  | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 5560360793     |
    | john@happymutts.com | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 2120000142     |
    | anna@dogsrus.com    | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 5562252998     |
    | emma@weluvdogs.com  | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 5569467466     |

  And the following applications exist:
    | user_email          | company_number | state    | categories      |
    | fred@barkyboys.com  | 5560360793     | accepted | Groomer, Trainer|
    | john@happymutts.com | 2120000142     | accepted | Psychologist    |
    | anna@dogsrus.com    | 5562252998     | accepted | Trainer         |
    | emma@weluvdogs.com  | 5569467466     | accepted | Groomer, Walker |


  Given the date is set to "2018-10-01"


@selenium @time_adjust @visitor
Scenario: Visitor checks search near me (visitor location = Stockholm)
Given I am logged out
And I am on the "landing" page
And I should see xpath "//*[@id='map']"
   # FIXME how to do this?
#And the search near me checkbox on the map should be unchecked
   # FIXME how to do this?
#When I check the search near me checkbox on the map
Then I should see "4" companies


@selenium @time_adjust @visitor
Scenario: Visitor unchecks search near me
  Given I am logged out
  And I am on the "landing" page
  #And my location is 19.123, 49.0
  #And I uncheck the search near me checkbox on the map
  Then I should see "4" companies



  @selenium @time_adjust @visitor
Scenario: Visitor location not available
  Given I am logged out
  And I am on the "landing" page
  #And my location is not available
  #And I check the search near me checkbox on the map
  Then I should see "4" companies
