When(/^I choose a file named "([^"]*)" to upload$/) do | filename |
  page.attach_file "uploaded_file[actual_file]", File.join(Rails.root, 'spec', 'fixtures','uploaded_files', filename)
end

And(/^I should see "([^"]*)" uploaded for this membership application$/) do |filename|
  expect(page).to have_selector('.uploaded-file', text: filename)
end

And(/^I should not see "([^"]*)" uploaded for this membership application$/) do |filename|
  expect(page).not_to have_selector('.uploaded-file', text: filename)
end

And(/^I should see (\d+) uploaded files listed$/) do |number|
  expect(page).to have_selector('.uploaded-file', count: number)
end
