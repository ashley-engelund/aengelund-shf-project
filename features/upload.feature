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


  Scenario: Upload a file
    Given I am on the "submit new membership application" page
    When I choose a file named "diploma.pdf" to upload
    And I click on "Upload File"
    Then I should be on "submit new membership application" page
    And I should see "Your file was successfully uploaded"
    And I should see "Files uploaded for this application"
    And I should see "diploma.pdf" uploaded for this membership application

    # submitting is a separate action: a separate button and submits everything.

    # might we have already submitted the application? might we be editing or adding to it?

  Scenario: Upload a second file
    Given I am on the "submit new membership application" page
    And there is a file named "diploma.pdf" uploaded for this membership application
    When I choose a file named "picture.jpg" to upload
    And I click on "Upload File"
    Then I should be on "submit new membership application" page
    And I should see "Your file was successfully uploaded"
    And I should see "Files uploaded for this application"
    And I should see "diploma.pdf" uploaded for this membership application
    And I should see "picture.jpg" uploaded for this membership application
    And I should see 2 uploaded files listed



  # as an admin, I should see the files uploaded for an application

  # delete files that I've uploaded?
  Scenario: User deletes a file that was uploaded


  # when I edit: see the files I've uploaded...
  Scenario: User uploads a file to an existing membership application



  # Future scenario? (put in PT?) Admin needs to attach an emailed file to a user's membership application

  # Future scenario? (put in PT?) Admin needs to delete a file attached to a user's membership information