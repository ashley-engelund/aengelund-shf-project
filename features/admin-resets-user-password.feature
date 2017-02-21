Feature: As an admin
  So that I can help users that forgot their password (who can't reset it themselves via email)
  I need to be able to reset passwords for users


  Background:

    Given the following users exists
      | email               | admin |
      | emma@happymutts.com |       |
      | bob@snarkybarky.se  |       |
      | admin@shf.se        | true  |

    And the following companies exist:
      | name        | company_number | email               |
      | Happy Mutts | 2120000142     | bowwow@bowsersy.com |

    And the following applications exist:
      | first_name | user_email          | company_number | state    |
      | Emma       | emma@happymutts.com | 2120000142     | accepted |


    And I am logged in as "admin@shf.se"


  Scenario: A member needs their password reset
    Given I am on the user page for "emma@happymutts.com"
    When I click on the t("reset_password") button
    Then I should see t("new_password_is")
       # ex English: 'The new password is:'
    And I should see t("please_note_new_password")
      # ex English: 'Please record this in a safe and secure place.  Once you leave this screen you will not be able to see it again.'

  Scenario: A user needs their password rest
    Given I am on the user page for "bob@snarkybarky.se"
    When I click on the t("reset_password") button
    Then I should see t("new_password_is")
       # ex English: 'The new password is:'
    And I should see t("please_note_new_password")
      # ex English: 'Please record this in a safe and secure place.  Once you leave this screen you will not be able to see it again.'
