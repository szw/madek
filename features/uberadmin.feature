Feature: Acting as an Uberadmin

  @jsbrowser
  Scenario: Becoming an Uberadmin, viewing things, and leaving Ueberadmin-Mode
    Given I am signed-in as "Adam"
    And I visit "/media_resources?filterpanel=true"
    And I remember the number of resources
    And I click on "Adam Admin"
    And I click on "Werde Überadmin" 
    Then I can see more resources than before
    And I can see all resources
    When I click on "Adam Admin"
    And I click on "Verlasse Überadmin-Modus"
    Then I see exactly the same number of resources as before


    
