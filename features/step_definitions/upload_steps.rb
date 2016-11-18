

When(/^I choose a file named "([^"]*)" to upload$/) do | filename |
  page.attach_file :upload_file, File.join(Rails.root, 'spec', 'fixtures','uploaded_files', filename)
end

And(/^I should see "([^"]*)" uploaded for this membership application$/) do |filename|
  expect(page).to have_selector('.uploaded_file', text: filename)
end

And(/^I should not see "([^"]*)" uploaded for this membership application$/) do |filename|
  expect(page).not_to have_selector('.uploaded_file', text: filename)
end

And(/^there is a file named "([^"]*)" uploaded for this membership application$/) do |filename|
  pending
  # FIXME how do we test for this? test for file existence give the Paperclip configuration path set for this environment
end

And(/^I should see (\d+) uploaded files listed$/) do |number|
  expect(page).to have_selector('.uploaded_file', count: number)
end

