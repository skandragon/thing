Feature: The menu works
In order to ...
I want to be able to ...
So that I can ...

  Background:
    Given I go to the home page

  Scenario: "Thing" is in the brand location
    Then I should see "Thing" within ".brand"

  Scenario: The "Thing" brand is a link to the home page
    When I click on "Thing"
    Then I should be on the home page
  
  Scenario: The About link takes me to the about page
    When I click on "About"
    Then I should be on the about page
