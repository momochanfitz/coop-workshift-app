Feature: Set User Preferences for Schedule
  As a co-op member
  In order to be assigned shifts at times that I can work
  I would like to be able to set my schedule preferences for the semester.

  Background:
    Given I am logged in as a member
    And I am on the set preferences page
    
  @wip
  Scenario: A user sets their time preferences correctly
    And I fill in my availability correctly
    Then I should see "yes" "10" times
    And I should see "can't" "10" times
    And I fill in "Notes" with "I have nothing to say"
    Then I press "Submit"
    Then I should see "Your preferences have been set"
    
  @wip    
  Scenario: A user sets their time preferences Incorrectly (Leave them Blank)
    And I fill in "Notes" with "I have nothing to say"
    Then I press "Submit"
    Then I should see "Error, you must fill in all the boxes."
