Feature: Alerts for past due H-branding fee sent; company HAS previous H-Branding fee payments (a Condition response)

  As a nightly task
  So that users are notified ('alerted') if payment for the H-branding fee
  is not paid for a company they are associated with,
  alert them of this by sending an email to them.

  (reminder: "current member" = approved AND paid membership fee)

  From the comments in HBrandingFeePastDueAlert:

  The first day the H-branding fee is due (a.k.a "day zero") is
  IF an H-branding fee has ever been paid,
  it is 1 day after the latest expiration date of the latest H-branding fee payment
  ELSE
  it is the date of the _earliest_ membership fee payment of the current members in the company.


  Ex:  no H-branding fee has ever been paid

  member 1 membership exp = Jan 1
  member 2 membership exp = Jan 2

  ===>  day 0 for h-branding fee = the earliest membership start (paid) date
  of the _current members_ of the company

  the first 'H-Branding fee is past due' email will go out on Jan. 2  ( = 1 day past due)


  Ex:  H-branding fee was paid on July 1, 2017 and expired on June 30, 2018
  Today is August 6, 2019

  member 1 membership exp = Jan 1, 2019
  member 2 membership exp = Jan 2, 2020

  ===>  day 0 for h-branding fee = July 1, 2018, the day after the last H-Branding fee payment expired

  the first 'H-Branding fee is past due' email will go out on July 2, 2018  ( = 1 day past due)
  Since today  is August 6, 2019, an alert will only go out if the
  Condition configuration [:days] includes 400. ( Date.new(2019, 8, 6) - Date.new(2018, 7,2) = 400 )


  Background:

    Given the following users exists
      | email                                      | admin | member |
      | memb01_exp_18_1_3@mutts-exp-17-6-6.se      |       | true   |
      | memb02_exp-17-1-4@mutts-exp-17-6-6.se      |       | true   |
      | memb06_exp_19-1-16@voof-exp-19-1-16.se     |       | true   |
      | memb07_exp_19-1-17@voof-exp-19-1-16.se     |       | true   |
      | memb20_exp_19-3-2@happymutts-exp-19-3-2.se |       | true   |
      | memb21_exp_20-3-1@happymutts-exp-19-3-2.se |       | true   |
      | user30@barko-not-approved-yet.se           |       | false  |
      | admin@shf.se                               | true  |        |


    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |


    Given the following regions exist:
      | name      |
      | Stockholm |


    Given the following companies exist:
      | name                               | company_number | email                           | region    |
      | Voof HBrand Expires 2019-1-16      | 2120000142     | hello@voof-exp-19-1-16.se       | Stockholm |
      | Mutts R Us HBrand Expires 2017-6-6 | 5562252998     | hello@mutts-exp-17-6-6.se       | Stockholm |
      | HappyMutts Paid Until 2019-3-2     | 2664181183     | hello@happymutts-exp-19-3-2.se  | Stockholm |
      | Barko App Not Approved             | 5236280540     | hello@barko-not-approved-yet.se | Stockholm |


    And the following applications exist:
      | user_email                                 | company_number | categories | state        | when_approved |
      | memb01_exp_18_1_3@mutts-exp-17-6-6.se      | 5562252998     | rehab      | accepted     | 2018-01-03    |
      | memb02_exp-17-1-4@mutts-exp-17-6-6.se      | 5562252998     | rehab      | accepted     | 2018-01-04    |
      | memb06_exp_19-1-16@voof-exp-19-1-16.se     | 2120000142     | rehab      | accepted     | 2018-01-13    |
      | memb07_exp_19-1-17@voof-exp-19-1-16.se     | 2120000142     | rehab      | accepted     | 2018-01-14    |
      | memb20_exp_19-3-2@happymutts-exp-19-3-2.se | 2664181183     | rehab      | accepted     | 2018-03-01    |
      | memb21_exp_20-3-1@happymutts-exp-19-3-2.se | 2664181183     | rehab      | accepted     | 2018-03-01    |
      | user30@barko-not-approved-yet.se           | 5236280540     | rehab      | under_review |               |


    # Note the expiration dates for the H-Branding license (branding_fee) payments for the companies
    #  and the dates for the # days past due after each expiration date:
    #
    #                                         Days past due:
    # Company                    expire_date    1          32         42         60         363
    # -------------------------  -----------  ---------- ---------- ---------- ---------- ----------
    # @mutts-exp-17-6-6.se       2017-6-6     2017-06-08 2017-07-09 2017-07-19 2017-08-06 2018-06-05
    # @voof-exp-19-1-16.se       2019-1-16    2019-01-18 2019-02-18 2019-02-28 2019-03-18 2020-01-15
    # @happymutts-exp-19-3-2.se  2019-3-2     2019-03-04 2019-04-04 2019-04-14 2019-05-02 2020-02-29

    And the following payments exist
      | user_email                                 | start_date | expire_date | payment_type | status | hips_id | company_number |
      | memb01_exp_18_1_3@mutts-exp-17-6-6.se      | 2017-1-4   | 2018-1-3    | member_fee   | betald | none    |                |
      | memb02_exp-17-1-4@mutts-exp-17-6-6.se      | 2016-1-5   | 2017-1-4    | member_fee   | betald | none    |                |
      | memb02_exp-17-1-4@mutts-exp-17-6-6.se      | 2016-6-5   | 2017-6-6    | branding_fee | betald | none    | 5562252998     |
      | memb06_exp_19-1-16@voof-exp-19-1-16.se     | 2018-1-17  | 2019-1-16   | member_fee   | betald | none    |                |
      | memb06_exp_19-1-16@voof-exp-19-1-16.se     | 2018-1-17  | 2019-1-16   | branding_fee | betald | none    | 2120000142     |
      | memb07_exp_19-1-17@voof-exp-19-1-16.se     | 2018-1-18  | 2019-1-17   | member_fee   | betald | none    |                |
      | memb20_exp_19-3-2@happymutts-exp-19-3-2.se | 2018-3-3   | 2019-3-2    | member_fee   | betald | none    |                |
      | memb20_exp_19-3-2@happymutts-exp-19-3-2.se | 2018-3-3   | 2019-3-2    | branding_fee | betald | none    | 2664181183     |
      | memb21_exp_20-3-1@happymutts-exp-19-3-2.se | 2019-3-2   | 2020-3-1    | member_fee   | betald | none    |                |


    Given there is a condition with class_name "HBrandingFeePastDueAlert" and timing "after"
    Given the condition has days set to [1, 32, 42, 60, 363 ]


  #Scenario Outline: Past H-Brand fees were paid but H-Brand license is expired


  Scenario Outline: HBrand fees paid, has expired; 1 member current until 18-1-3


    Given the date is set to <today>
    And the process_condition task sends "condition_response" to the "HBrandingFeePastDueAlert" class
    Then "memb01_exp_18_1_3@mutts-exp-17-6-6.se" should receive <member01_email> email
    And "memb02_exp-17-1-4@mutts-exp-17-6-6.se" should receive <memb02_email> email
    And "memb06_exp_19-1-16@voof-exp-19-1-16.se" should receive <memb06_email> email
    And "memb07_exp_19-1-17@voof-exp-19-1-16.se" should receive <memb07_email> email
    And "memb20_exp_19-3-2@happymutts-exp-19-3-2.se" should receive no email
    And "memb21_exp_20-3-1@happymutts-exp-19-3-2.se" should receive no email

    # checking the day before and after the alert day just to be sure no emails are sent then
    Scenarios:
      | today        | member01_email | memb02_email | memb06_email | memb07_email |
      | "2017-06-07" | no             | no           | no           | no           |
      | "2017-06-08" | an             | no           | no           | no           |
      | "2017-07-09" | an             | no           | no           | no           |
      | "2017-07-18" | no             | no           | no           | no           |
      | "2017-07-19" | an             | no           | no           | no           |
      | "2017-07-20" | no             | no           | no           | no           |
      | "2017-08-7"  | no             | no           | no           | no           |
      | "2017-08-06" | an             | no           | no           | no           |
      | "2017-08-07" | no             | no           | no           | no           |
      | "2018-06-05" | no             | no           | no           | no           |


  Scenario Outline: HBrand fees paid, not expired at start; 1 member current until 18-1-3
    # Has not expired for the @voof... company. Which is what we're interested in

    Given the date is set to <today>
    And the process_condition task sends "condition_response" to the "HBrandingFeePastDueAlert" class
    Then "memb01_exp_18_1_3@mutts-exp-17-6-6.se" should receive <member01_email> email
    And "memb02_exp-17-1-4@mutts-exp-17-6-6.se" should receive <memb02_email> email
    And "memb06_exp_19-1-16@voof-exp-19-1-16.se" should receive <memb06_email> email
    And "memb07_exp_19-1-17@voof-exp-19-1-16.se" should receive <memb07_email> email
    And "memb20_exp_19-3-2@happymutts-exp-19-3-2.se" should receive <memb20_email> email
    And "memb21_exp_20-3-1@happymutts-exp-19-3-2.se" should receive <memb21_email> email

    Scenarios:
      | today        | member01_email | memb02_email | memb06_email | memb07_email | memb20_email | memb21_email |
      | "2019-1-02"  | no             | no           | no           | no           | no           | no           |
      | "2019-01-18" | no             | no           | no           | no           | no           | no           |
      | "2019-02-18" | no             | no           | no           | no           | no           | no           |
      | "2019-02-28" | no             | no           | no           | no           | no           | no           |
      | "2019-03-04" | no             | no           | no           | no           | no           | an           |
      | "2019-03-18" | no             | no           | no           | no           | no           | no           |
      | "2019-04-04" | no             | no           | no           | no           | no           | an           |
      | "2019-04-14" | no             | no           | no           | no           | no           | an           |
      | "2019-05-02" | no             | no           | no           | no           | no           | an           |
      | "2020-01-15" | no             | no           | no           | no           | no           | no           |
      | "2020-02-29" | no             | no           | no           | no           | no           | an           |

