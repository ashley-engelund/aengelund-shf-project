Feature: Admin sets or enters the reason they are waiting for info from a user
  As an admin
  so that SHF can talk with the user specifically about why they are waiting and know how long they might need to wait,
  I need to set the reason why SHF is waiting
  and if the reason is not available from a list,
  I need to be able to type in text that describes the situation

  PT: https://www.pivotaltracker.com/story/show/143810729

  Background:
    Given the following users exists
      | email                 | admin |
      | emma@happymutts.se    |       |
      | admin@shf.com         | true  |

    Given the following business categories exist
      | name         | description                     |
      | rehab        | physcial rehabitation           |

    Given the following regions exist:
      | name         |
      | Stockholm    |

    Given the following companies exist:
      | name                 | company_number | email                 | region    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.se | Stockholm |


    And the following applications exist:
      | first_name | user_email            | company_number | category_name | state   |
      | Emma       | emma@happymutts.se    | 5562252998     | rehab         | waiting_for_applicant |

    And I am logged in as "admin@shf.com"


  Scenario: Admin selects 'need more documentation' as the reason SHF is waiting_for_applicant
    Given I am on "Emma" application page
    When I set "reason_list" to t("membership_applications.need_info.reason.need_documentation")
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see t("membership_applications.need_documentation")



  Scenario: Admin selects 'waiting for payment' as the reason SHF is waiting_for_applicant
    Given I am on "Emma" application page
    When I set "reason_list" to t("membership_applications.need_info.reason.waiting_for_payment")
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see t("membership_applications.waiting_for_payment")


  Scenario: Admin selects 'other' and enters text as the reason SHF is waiting_for_applicant
    Given I am on "Emma" application page
    When I set "reason_list" to t("membership_applications.need_info.reason.other")
    And I fill in "custom_reason" with "This is my reason"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see t("membership_applications.need_info.reason.other")
    And I should see "This is my reason"


  Scenario: things go wrong
