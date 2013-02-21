def find_modal_element(target)
  wait_until { page.find(target).visible? }
end

Then /^I should see a popup window$/ do
 find_modal_element('#deleteModal')
 page.find('#deleteModal').should have_content "This action cannot be undone"
end
