Feature: Home Page
In order to look at the cool home page
I want it to render properly and show me links I need
So that I can navigate the site.

  Scenario: render home page
    When I go to the home page
    Then I should see "Thing"

  Scenario: Home page has standard menu items
    When I go to the home page
    Then I should see "About"
