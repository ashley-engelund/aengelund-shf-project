Feature: Admins get emails when a member has been unpaid for 6 months

  As a nightly task,
  so that admins can check to see if lapsed members are still using the H-markt image but shouldn't be,
  assuming that anyone that still hasn't paid after 6 months is not going to pay for membership,
  Send an email to the membership address (not the admins!) with all members that are unpaid for 6 months.


  Background:

    Given the following users exists
      | email                       | admin | member |
      | member01_exp_jun_1@mutts.se |       | true   |
      | member02_exp_jun_1@mutts.se |       | true   |
      | member03_new_app@mutts.se   |       | false  |
      | member04_rejected@mutts.se  |       | false  |
      | member06_exp_jun_2@mutts.se |       | true   |
      | admin_1@shf.se              | true  |        |
      | admin_2@shf.se              | true  |        |

    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name       | company_number | email         | region    |
      | Mutts R Us | 5562252998     | voof@mutts.se | Stockholm |


    # Note that 2 are not members: member_03... and member04...
    And the following applications exist:
      | user_email                  | company_number | categories | state    |
      | member01_exp_jun_1@mutts.se | 5562252998     | rehab      | accepted |
      | member02_exp_jun_1@mutts.se | 5562252998     | rehab      | accepted |
      | member03_new_app@mutts.se   | 5562252998     | rehab      | new      |
      | member04_rejected@mutts.se  | 5562252998     | rehab      | rejected |
      | member06_exp_jun_2@mutts.se | 5562252998     | rehab      | accepted |



    # Everyone in company "happymutts.se" is paid: the H-branding fee is paid
    And the following payments exist
      | user_email                  | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member01_exp_jun_1@mutts.se | 2017-07-02 | 2018-07-01  | member_fee   | betald | none    |                |
      | member02_exp_jun_1@mutts.se | 2017-07-02 | 2018-07-01  | member_fee   | betald | none    |                |
      | member06_exp_jun_2@mutts.se | 2017-07-03 | 2018-07-02  | member_fee   | betald | none    |                |


    Given there is a condition with class_name "MemberUnpaidFor6MonthsAlert" and timing "every_day"
    Given the condition has the month day set to 12

  @condition
  Scenario Outline: Members that are unpaid by exactly 6 months today. Email goes to medlem@sverigeshundforetagare.se
    Given the date is set to <today>
    And the process_condition task sends "condition_response" to the "MemberUnpaidFor6MonthsAlert" class
    Then "medlem@sverigeshundforetagare.se" should receive <medlem_email> email
    And "admin_1@shf.se" should receive no email
    And "admin_2@shf.se" should receive no email
    And "member01_exp_jan_3@mutts.se" should receive no email
    And "member02_exp_jan_4@mutts.se" should receive no email
    And "member03_new_app@mutts.se " should receive no email
    And "member04_rejected_app@mutts.se " should receive no email


    Scenarios:
      | today        | medlem_email |
      | "2018-12-31" | no           |
      | "2019-1-01"  | an           |
      | "2019-1-02"  | an           |
      | "2019-1-03"  | no           |
