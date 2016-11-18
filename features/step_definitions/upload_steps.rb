

When(/^I choose a file named "([^"]*)" to upload$/) do |arg|
  attach_file  # TODO attach to what field, path to the file
  # TODO path to the file = from config/test.rb

end

And(/^I should see "([^"]*)" uploaded for this membership application$/) do |arg|
  pending
  # is this really any different from just seeing content on the page?
  # expect the specific <div> to have this content
  # FIXME expect(page).to
end

And(/^there is a file named "([^"]*)" uploaded for this membership application$/) do |arg|
  pending
  # FIXME how do we test for this?  (stub it out here with a fixture)
end

And(/^I should see (\d+) uploaded files listed$/) do |number|
  expect(page).to have_selector('.uploaded_files', count: number)
end