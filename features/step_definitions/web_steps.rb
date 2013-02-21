When /^I go to (.*)$/ do |page|
  visit path_to(page)
end

When /^I should be on (.*)$/ do |page|
  current_path.should == path_to(page)
end

Then /^I should see "([^"]+)"$/ do |content|
  page.should have_content(content)
end

Then /^I should not see "([^"]+)"$/ do |content|
  page.should_not have_content(content)
end

Then /^I should see "(.*?)" within "(.*?)"$/ do |content, selector|
  found = false
  page.all(:css, selector).each do |item|
    found ||= item.has_content?(content)
  end
  found.should == true
end

Then /^I should not see "(.*?)" within "(.*?)"$/ do |content, selector|
  page.all(:css, selector).each do |item|
    item.should_not have_content(content)
  end
end

Then /^I should see a "(.*?)" (button|link)$/ do |thing_name, thing_type|
  if thing_type == "button"
    page.should have_button(thing_name)
  else
    page.should have_link(thing_name)
  end
end

When /^I click on "(.*?)"$/ do |link|
  click_on link
end

When /^I select "(.*?)" for "(.*?)"$/ do |value, field|
  select(value, from: field)
end

When /^I fill in "([^"]+)" with "([^"]*)"$/ do |field, value|
  fill_in field, with: value
end
