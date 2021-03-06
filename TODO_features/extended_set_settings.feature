Feature: Setting set cover of a set, Saving display settings

  As a MAdeK user
  I want to set up extended settings for sets

  Background: Load the example data and personas
    Given personas are loaded
      And I am "Normin"

  @poltergeist
  Scenario: Set the cover of a set by hand
    When I see the detail view of a set with media entries that I can edit
    Then I can open the set cover dialog
     And I see a list of media entries which are inside that set
    When I choose one of that media resources
    Then that media resource is displayed as cover of that set

  @poltergeist
  Scenario: Try to set the cover of a set by hand when there are no children
    When I see the detail view of a set that I can edit which has no children
     And I can open the set cover dialog
    Then I should see an information that this set is empty

  @poltergeist
  Scenario: Set the cover of a set automatically
    When I add media resources to an empty set
    Then one of these media resources is set as the cover for that set automatically

  Scenario: Display the cover of a set
    When a set is empty
    Then it has no cover
    When a set contains only sets
    Then it has no cover
    When a set has a cover
    Then that cover is displayed

  @javascript
  Scenario: Save display settings of a set
    When I see the detail view of a public set that I can edit
     And I changed the layout
     And I changed the sorting
     And I save that display settings
    When another user visits the detail view of that set
    Then he sees the content of that set according to the saved display settings
    
