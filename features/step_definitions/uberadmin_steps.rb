Then(/^I can see all resources$/) do
  expect(find("#resources_counter").text.to_i).to eq MediaResource.count
end

Then(/^I can see more resources than before$/) do
  expect(find("#resources_counter").text.to_i).to be > @resources_counter
end


Then(/^I see exactly the same number of resources as before$/) do
  expect(find("#resources_counter").text.to_i).to eq @resources_counter
end
