Feature: importing an image

  @firefox
  Scenario: Importing images and setting some metadata
    Given I am signed-in as "Normin"
    And I am going to import images

    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    And I attach the file "images/date_should_be_1990.jpg"
    And I attach the file "images/date_should_be_2011-05-30.jpg"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I wait until there are no more ajax requests running and no delays are pending
    And I click on the link "Weiter..." 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    Then there are "3" new media_entries
    And there is a entry with the title "Berlin Wall" in the new media_entries

  @firefox
  Scenario: Highlighting and enforcing required meta fields
    Given I am signed-in as "Normin"
    And I am going to import images
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    When I click on the link "Weiter"
    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    Then I can see that the fieldset with "title" as meta-key is required
    Then I can see that the fieldset with "copyright notice" as meta-key is required
    When I click on the link "Weiter..." 

    Then I am on the "/import/meta_data" page
    And I see an error alert
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I wait until there are no more ajax requests running and no delays are pending
    And I click on the link "Weiter..." 
    And I wait until I am on the "/import/organize" page

  @firefox
  Scenario: Setting permissions during the import
    Given I am signed-in as "Normin"
    And I am going to import images
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I set the input with the name "user" to "Paula, Petra"
    And I click on "Paula, Petra" inside the autocomplete list
    Then the "view" permission for "Paula, Petra" is checked
    When I click on the "download" permission for "Paula, Petra"
    Then the "download" permission for "Paula, Petra" is checked
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I wait until there are no more ajax requests running and no delays are pending
    And I click on the link "Weiter..." 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    And there is a entry with the title "Berlin Wall" in the new media_entries
    And Petra has "view" user-permission on the new media_entry with the tile "Berlin Wall"
    And Petra has "download" user-permission on the new media_entry with the tile "Berlin Wall"

  @firefox 
  Scenario: Adding the imports to a new set 
    Given I am signed-in as "Normin"
    And I am going to import images

    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    And I attach the file "images/date_should_be_1990.jpg"
    And I attach the file "images/date_should_be_2011-05-30.jpg"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I wait until there are no more ajax requests running and no delays are pending
    And I click on the link "Weiter..." 

    And I wait until I am on the "/import/organize" page
    And I click on the link "Einträge zum einem Set hinzufügen"
    And I wait for the dialog to appear
    And I set the input with the name "search_or_create_set" to "Import Test Set"
    And I click on the button "Neues Set erstellen"
    And I click on the button "Speicher"
    And I wait for the dialog to disappear
    And I click on the button "Import abschliessen"

    Then there are "3" new media_entries


