Feature: importing an image

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


