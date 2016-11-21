Feature: As an applicant
  In order to show my credentials
  I need to be able to upload files
  PT: https://www.pivotaltracker.com/story/show/133109591


  ##--
  # Here's another way to state the feature:
  #
  # As a potential member
  # So that I can provide proof of my professional education
  # And qualify for membership
  # I need to upload a file with the education information
  # And attach it to my membership application

  ##
  #As an admin
  #So that I can accept or reject a membership application
  #I need to view any files attached to a membership application


  # given I'm applying for a members  I'm on on a membership page...
  # I should be able to click a button to attach/ upload a document
  #   (must be able to submit the application in order have documents uploaded)


  Background:
    Given the following users exists
      | email                  |
      | applicant_1@random.com |


    And the following applications exist:
      | company_name       | user_email             |
      | My Dog Business    | applicant_1@random.com |

    And I am logged in as "applicant_1@random.com"


  Scenario: Upload a file during a new application
    Given I am on the "submit new membership application" page
    When I choose a file named "diploma.pdf" to upload
    And I fill in "Company Name" with "Craft Academy"
    And I fill in "Company Number" with "1234561234"
    And I fill in "Contact Person" with "Thomas"
    And I fill in "Company Email" with "info@craft.se"
    And I fill in "Phone Number" with "031-1234567"
    And I click on "Submit"
    And I am on the "edit my application" page
    Then I should see "Files uploaded for this application:"
    And I should see "diploma.pdf" uploaded for this membership application

  Scenario: Upload a file for an existing application
    Given I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I fill in "Company Name" with "Craft Academy"
    And I fill in "Company Number" with "1234561234"
    And I fill in "Contact Person" with "Thomas"
    And I fill in "Company Email" with "info@craft.se"
    And I fill in "Phone Number" with "031-1234567"
    And I click on "Submit"
    Then I should see "Files uploaded for this application:"
    And I should see "diploma.pdf" uploaded for this membership application


  Scenario: Upload a second file
    Given I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on "Submit"
    And I am on the "edit my application" page
    When I choose a file named "picture.jpg" to upload
    And I click on "Submit"
    Then I should see "Files uploaded for this application:"
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see 2 uploaded files listed

  Scenario: Upload multiple files at one time (multiple select)
    Given I am on the "edit my application" page
    When I choose the files named ["picture.jpg", "picture.png", "diploma.pdf"] to upload
    And I click on "Submit"
    Then I should see "Files uploaded for this application:"
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see "picture.png" uploaded for this membership application
    And I should see 3 uploaded files listed


  Scenario: Try to upload a file with unacceptable content type
    Given I am on the "edit my application" page
    When I choose a file named "tred.exe" to upload
    And I click on "Submit"
    Then I should see "Sorry, this is not a file type you can upload."
    And I should not see "not-accepted.exe" uploaded for this membership application

  # as an admin, I should see the files uploaded for an application


  Scenario: User deletes a file that was uploaded
    Given I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on "Submit"
    And I am on the "edit my application" page
    And I click on trash icon for "diploma.pdf"
    Then I should not see "diploma.pdf" uploaded for this membership application


  Scenario: User uploads a file to an existing membership application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "edit my application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on "Submit"
    Then I should see "Files uploaded for this application:"
    And I should see "diploma.pdf" uploaded for this membership application


  # Future scenario? (put in PT?) Admin needs to attach an emailed file to a user's membership application

  # Future scenario? (put in PT?) Admin needs to delete a file attached to a user's membership information