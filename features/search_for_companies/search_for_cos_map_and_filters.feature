Feature: Search for Companies with Filters and Map

As someone using the site
In order to find companies that I might want to work with
I want to search for available companies by various criteria including near me.



Background:
  Given the following users exists
    | email                | admin | member |
    | visitor@ex.com       |       | false  |
    | fred@barkyboys.com   |       | true   |
    | john@happymutts.com  |       | true   |
    | anna@dogsrus.com     |       | true   |
    | emma@weluvdogs.com   |       | true   |
    | lars@nopayment.se    |       | true   |
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
    | NoPayment   | 8028973322     | hello@nopayment.se   | Stockholm    | Alingsås  |
    | NoMember    | 9697222900     | hello@nomember.se    | Stockholm    | Alingsås  |

  And the following payments exist
    | user_email          | start_date | expire_date | payment_type | status | hips_id | company_number |
    | fred@barkyboys.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
    | john@happymutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
    | anna@dogsrus.com    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5562252998     |
    | emma@weluvdogs.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5569467466     |

  And the following applications exist:
    | user_email          | company_number | state    | categories      |
    | fred@barkyboys.com  | 5560360793     | accepted | Groomer, Trainer|
    | john@happymutts.com | 2120000142     | accepted | Psychologist    |
    | anna@dogsrus.com    | 5562252998     | accepted | Trainer         |
    | emma@weluvdogs.com  | 5569467466     | accepted | Groomer, Walker |
    | lars@nopayment.se   | 8028973322     | accepted | Groomer, Trainer|

  Given the date is set to "2017-10-01"


@selenium @time_adjust @visitor
Scenario: Visitor filters by category then map


@selenium @time_adjust @visitor
Scenario: Visitor filters by map then category


@selenium @time_adjust @member
Scenario: Member checks search near me, then filters by category, then unchecks search near me


@selenium @time_adjust @admin
Scenario: Admin filters by map then category


