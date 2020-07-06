Feature: Who can access a member's Proof of Membership download page


  Background:
    Given the App Configuration is not mocked and is seeded
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist
      | email                | admin | member | membership_number | first_name | last_name |
      | admin@shf.se         | true  |        |                   | Admin      | Admin     |
      | member-emma@mutts.se |       | true   | 1001              | Emma       | Member    |
      | member-lars@mutts.se |       | true   | 1002              | Lars       | Member    |


    Given the following business categories exist
      | name  | description                                    |
      | groom | grooming dogs from head to tail and back again |

    Given the following applications exist:
      | user_email           | company_number | categories | state    |
      | member-emma@mutts.se | 5562252998     | groom      | accepted |
      | member-lars@mutts.se | 5562252998     | groom      | accepted |

    Given the date is set to "2017-11-01"

    Given the following payments exist
      | user_email           | start_date | expire_date | payment_type | status | hips_id |
      | member-emma@mutts.se | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |
      | member-lars@mutts.se | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |


  Scenario: An admin can see a member's proof of membership
    Given I am logged in as "admin@shf.se"


  Scenario: A member can access their own proof of membership download page
    Given I am logged in as "member-emma@mutts.se"


  Scenario: A member cannot access someone else's proof of membership download page
    Given I am logged in as "member-emma@mutts.se"


  Scenario: A visitor cannot access the proof of membership download image for a member
    Given I am logged out


