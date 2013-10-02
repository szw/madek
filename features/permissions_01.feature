Feature: Permissions
  As an user I want to have different permissions on resources
  So that I can decide who has what kind of access to my data

  As an owner of a Resource, I want to assign various permissions
  to users and groups.

  @jsbrowser 
  Scenario: Assigning and removing user permissions
    Given I am signed-in as "Normin"
    And I remove all permissions from my first media_entry
    And I visit the path of my first media entry
    And I open the edit-permissions dialog
    And I set the autocomplete-input with the name "user" to "Paula, Petra"
    And I click on "Paula, Petra" inside the autocomplete list
    Then the "view" permission for "Paula, Petra" is checked
    When I click on the "download" permission for "Paula, Petra"
    Then the "download" permission for "Paula, Petra" is checked
    And I click on the button "Speichern" 
    And I wait for the dialog to disappear
    Then User "petra" has "view" user-permissions for my first media_entry
    Then User "petra" has "download" user-permissions for my first media_entry
    Then User "petra" has not "edit" user-permissions for my first media_entry
    When I open the edit-permissions dialog
    And I remove "Paula, Petra" from the user-permissions
    And I click on the button "Speichern" 
    And I wait for the dialog to disappear
    Then "petra" has no user-permission for my first media_entry

  @jsbrowser 
  Scenario: Assigning group permissions
    Given I am signed-in as "Normin"
    And I remove all permissions from my first media_entry
    And I visit the path of my first media entry
    And I open the edit-permissions dialog
    And I set the autocomplete-input with the name "group" to "Zett"
    And I click on "Zett" inside the autocomplete list
    Then the "view" permission for "Zett" is checked
    When I click on the "download" permission for "Zett"
    Then the "download" permission for "Zett" is checked
    And I click on the button "Speichern" 
    And I wait for the dialog to disappear
    Then Group "Zett" has "view" group-permissions for my first media_entry
    Then Group "Zett" has "download" group-permissions for my first media_entry
    Then Group "Zett" has not "edit" group-permissions for my first media_entry
    When I open the edit-permissions dialog
    And I remove "Zett" from the group-permissions
    And I click on the button "Speichern" 
    And I wait for the dialog to disappear
    Then "Zett" has no group-permission for my first media_entry

  @jsbrowser
  Scenario: Display the complete LDAP name on the selection dropdown
    Given I am signed-in as "Normin"
    And I have set up some departments with ldap references
    And A resource owned by me with no other permissions
    When I visit the permissions dialog of the resource
    And I set the autocomplete-input with the name "group" to "Vertiefung Industrial Design"
    And I click on "Vertiefung Industrial Design (DDE_FDE_VID.dozierende)" inside the autocomplete list
    When I click on the submit button
    Then I am on the page of the resource
    And I see a confirmation alert

#Berechtigungen:
#Es gibt folgende Berechtigungen auf Ressourcen im Medienarchiv (In Klammer die deutschen Bezeichnungen des Interfaces):
#- View (Sehen): sehen einer Ressource
#- Edit (Editieren): editieren von Metadaten einer Ressource, hinzufügen und wegnehmen von Ressourcen zu einem Set
#- Download Original (Exportieren des Originals): Exportieren des originalen Files
#- Manage permissions: Verwalten der Berechtigungen auf einer Ressource
#- Ownership: Person, die eine Ressource importiert/erstellt hat, hat defaultmässig die Ownership und alle obigen Berechtigungen.
#- Nennt man eine Person oder eine Gruppe bei den Berechtigungen, wählt für diese aber keine Berechtigungen aus, so bedeutet dies, dass den genannten explizit die Berechtigungen entzogen sind.

# the notion of "ownership" has changed; a resource has an fkey pointing to a
# user, this is what used to be the 'owner' and is now called the 'responsible
# person' in the ui; the term 'owner' is still used in the specifications below

  Scenario: No permissions
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    And I visit the path of the resource
    Then I am redirected to the main page

  Scenario: View user-permission lets me view the resource
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    And I visit the path of the resource
    Then I see page for the resource

  Scenario: View group-permission lets me view the resource
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" group-permissions added for me to the resource
    And I visit the path of the resource
    Then I see page for the resource

  @jsbrowser 
  Scenario: Not manage user-permission won't let me edit permissions
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    And I visit the path of the resource
    And I open the edit-permissions dialog
    Then I can not edit the permissions

  @jsbrowser 
  Scenario: Manage permission
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    And There are "manage" user-permissions added for me to the resource
    And I visit the path of the resource
    And I open the edit-permissions dialog
    Then I can edit the permissions

  @jsbrowser
  Scenario: No edit user-permission won't let mit edit metadata
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    When I visit the edit path of the resource
    Then I see an error alert

  @jsbrowser
  Scenario: Edit user-permission will let me edit metadata
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    When There are "edit" user-permissions added for me to the resource
    And I visit the path of the resource
    And I click on the link "Weitere Aktionen"
    And I click on the link "Metadaten editieren"
    And I am on the edit page of the resource
    When I click on the submit button
    Then I am on the page of the resource
    And I see a confirmation alert


