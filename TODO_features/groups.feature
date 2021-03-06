Feature: Groups

  # https://www.pivotaltracker.com/story/show/23723319
  Scenario: Viewing the members of a group
    Given a group "Some People" with the members:
    |member|
    |Person A|
    |Person B|
    When I edit the permissions of a media entry
     And I give view permission to the group "Some People"
    Then I can choose to view a list of members of this group
     And the list contains:
    |members|
    |Person A|
    |Person B|

  Scenario: Viewing the group page
    Given a group "Some People" with the members:
    |member|
    |Person A|
    |Person B|
    Given I am a member of this group
    When I click on "my groups"
    Then I see a list of groups and the group "some people" is beneath them
    Then I can view all resources related to the group "some people"
    Then I can delete the group "some people"
