Feature: Managing Users and Logins

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Listing all groups with their types
    When I visit "/app_admin/groups"
    Then I see the column with a group type
    And I see the "Group" type in the group list
    And I see the "MetaDepartment" type in the group list

  Scenario: Filtering groups by their types
    When I visit "/app_admin/groups"
    Then I see a select input with "type" name
    And There is "all" group type option selected
    When I select "Group" from "form-control"
    And I submit
    Then I see groups with "Group" type
    And I don't see groups with "MetaDepartment" type
    And There is "group" group type option selected
    When I select "MetaDepartment" from "form-control"
    And I submit
    Then I see groups with "MetaDepartment" type
    And I don't see groups with "Group" type
    And There is "meta_department" group type option selected
