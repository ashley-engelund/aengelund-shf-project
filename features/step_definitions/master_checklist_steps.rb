# Steps for Master Checklist items

MASTER_LIST_ITEMS_LIST_ID = 'master-list-items'
MASTER_LIST_ITEMS_TABLE_ID = MASTER_LIST_ITEMS_LIST_ID
MASTER_ITEM_ROW_CSSCLASS = 'master-list-item'
MASTER_ITEM_CSSCLASS = MASTER_ITEM_ROW_CSSCLASS
NAME_CSSCLASS = 'name'
LIST_POSITION_CSSCLASS = 'list-position'
MASTER_ITEM_PARENT_LIST_ID = 'master-list-item-parent-id'


def get_master_checklist_table
  page.find_by_id(MASTER_LIST_ITEMS_TABLE_ID)
end


def xpath_str_for_item_span_name(item_name = '')
  xpathstr_ancestor_class_element_class_and_text(ancestor_class: MASTER_ITEM_CSSCLASS,
                                                 element_class: NAME_CSSCLASS,
                                                 text: item_name)
end


# this creates the xpath string for the li of the parent Master List Item, not the parent of the html element
def xpath_str_for_parent_item_li
  # get the grandparent li ( = li[2]), which will be the parent Master List Item
  './ancestor::li[2]'
end


# this creates the xpath string for the span of the parent Master List Item, not the parent of the html element
def xpath_str_for_parent_item_span_name(parent_name)
  # get the grandparent li ( = li[2]), which will be the parent Master List Item, and get the name of it (the "[a]/.... class='name'"
  "#{xpath_str_for_parent_item_li}/a/span[(#{xpath_for_element_with_class('name')}) and text()='#{parent_name}']"
end


# child number is ZERO based (first = zero(0)). But HTML element lists are not. Hence we add 1
def xpath_for_child_number_named(child_number, child_name)
  "./ol/li[#{child_number + 1}]/a/span[(#{xpath_for_element_with_class('name')}) and contains(text(), '#{child_name}')]"
end


# ---------------------------------------------------

And(/^I am (on )*the page for Master Checklist item named "([^"]*)"$/) do |_grammar_fix_on, list_name|
  checklist_master = AdminOnly::MasterChecklist.find_by_name(list_name)
  visit path_with_locale(admin_only_master_checklist_path checklist_master)
end


And(/^the following Master Checklist exist:$/) do |table|

  table.hashes.each do |item|
    name = item.delete('name') || ''
    displayed_text = item.delete('displayed_text') || ''
    description = item.delete('description') || ''
    list_position = (item.delete('list position') || '0').to_i
    parent_name = item.delete('parent name') || ''

    list_item = AdminOnly::MasterChecklist.find_by(name: name)
    list_item = FactoryBot.create(:master_checklist, name: name,
                                  displayed_text: displayed_text,
                                  description: description,
                                  parent_name: parent_name,
                                  list_position: list_position) if list_item.blank?
    list_item
  end
end


And("I should see {digits} Master Checklist listed") do |num_items|
  expect(page).to have_selector(".#{MASTER_ITEM_CSSCLASS}", count: num_items)
end

And("I should see the item named {capture_string} in the list of Master Checklist items") do |item_name|
  expect(page).to have_xpath(".//*[#{xpath_for_element_with_class(MASTER_ITEM_CSSCLASS)}]//*[#{xpath_for_element_with_class('name')} and contains(text(), '#{item_name}')]")
end


And("I should see the item named {capture_string} in the list of Master Checklist items as a child of {capture_string}") do |item_name, parent_name|
  child_xpath = xpath_str_for_item_span_name(item_name)
  expect(page).to have_xpath(child_xpath)
  child_item = page.find(:xpath, child_xpath)

  parent_span_xpath = xpath_str_for_parent_item_span_name(parent_name)
  expect(child_item).to have_xpath(parent_span_xpath)
end


And("I should see the item named {capture_string} in the list of Master Checklist items as child {digits}") do |item_name, child_number|
  child_xpath = xpath_str_for_item_span_name(item_name)
  expect(page).to have_xpath(child_xpath)

  list_start_id_xpath = "//div[@id='#{MASTER_LIST_ITEMS_TABLE_ID}']"
  expect(page).to have_xpath(list_start_id_xpath)
  list_id = page.find(:xpath, list_start_id_xpath)

  expect(list_id).to have_xpath(xpath_for_child_number_named(child_number, item_name))
end


And("I should see the item named {capture_string} in the list of Master Checklist items as child {digits} of {capture_string}") do |item_name, child_number, parent_name|
  child_xpath = xpath_str_for_item_span_name(item_name)
  expect(page).to have_xpath(child_xpath)

  child_item = page.find(:xpath, child_xpath)
  parent_span_xpath = xpath_str_for_parent_item_span_name(parent_name)
  expect(child_item).to have_xpath(parent_span_xpath)

  parent_li = child_item.find(:xpath, xpath_str_for_parent_item_li)
  expect(parent_li).to have_xpath(xpath_for_child_number_named(child_number, item_name))
end


# ---------
# Tables

And("I should see {digits} Master Checklist listed in the table") do |num|
  step %{I should see #{num} "#{MASTER_ITEM_ROW_CSSCLASS}" rows in the "#{MASTER_LIST_ITEMS_TABLE_ID}" table}
end


And("I should{negate} see {capture_string} in the Master Checklist items table") do |negate, item_text|
  step %{I should#{negate} see "#{item_text}" in the "#{MASTER_LIST_ITEMS_TABLE_ID}" table}
end


# TODO generalize this step so it can also be used by UserChecklists
And("I should{negate} see the item named {capture_string} in the Master Checklist items table and it shows position {digits}") do |negate, item_name, position|
  step %{I should#{negate} see "#{item_name}" in the Master Checklist items table}

  table = get_master_checklist_table
  item_name_td = table.find(:xpath, "tbody/tr/td[ (#{xpath_for_element_with_class(NAME_CSSCLASS)}) and (descendant::text()[contains(.,'#{item_name}')]) ]")
  item_name_row = item_name_td.find(:xpath, 'parent::tr') # get the parent tr of the td

  expect(item_name_row).to have_xpath(".//td[(#{xpath_for_element_with_class(LIST_POSITION_CSSCLASS)}) and .//text()='#{position}']")
end


And("I select {capture_string} as the parent list") do |parent_list_name|
  step %{I select "#{parent_list_name}" in select list "#{MASTER_ITEM_PARENT_LIST_ID}"}
end

