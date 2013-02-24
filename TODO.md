# Pennsic University Thing TODO

## Authorization

Authorization rankings allow specific permissions.  Each level generally
allows all actions a lesser ranked member may perform.

* Guest -- Can only see public information -- accepted classes, etc.
* User -- Can (eventually) manage their own subscriptions / watches, generate calendars, etc.
* Instructor -- can manage their instructor profile, and request classes to be taught.
* Coordinator -- Can approve classes and instructors
* PU Coordinator -- Can create coordinators
* Admin -- can do anything

## Tasks

### Basic Functionality

* <del>signup</del>
* <del>request to be a teacher form</del>
* <del>"request to teach a class" form (that is, class submission)</del>

### Administration

* <span class="low">(low) Send a password reset token to a user</span>
* <span class="high">(high) Allow editing of all aspects, other than password, for a user</span>
* <span class="high">(high) generate a list of email addresses for users who are instructors</span>
* <span class="high">(high) generate a list of email addresses for users who are tract leads</span>

### PU Coordinator

* <span class="high">(high) Assign a user to a tract lead position</span>


### Email Notifications

* <span class="medium">(medium) Send email to instructors when their class status changes</span>
* <span class="medium">(medium) Send email to tract leads when a class is assigned to their area</span>
* <span class="medium">(medium) Send email to PU admin when a new class is added</span>
* <span class="low">(low) Periodic email reminders</span>
   * Tract leads
      * Statistics about classes in their area
      * Listing of pending-accept classes
      * Listing of pending-schedule classes
      * Listing of all classes
      * Any scheduling conflicts
   * Administrators
      * New classes which were added and need a tract assigned
      * New instructors which were added
      * Statistics about the system
      * Any scheduling conflicts

### Coordinators

* <span class="high">(high) Enable coordinators' editing of classes assigned to their tract</span>
   * <span class="high">(high) A simple assign-to-location-and-time page</span>
* <span class="high">(high) listing of classes which need to be accepted</span>
* <span class="high">(high) listing of classes which need to be scheduled</span>
* <span class="high">(high) listing of all classes in a tract, by day, location, topic</span>
* <span class="high">(high) some sort of display showing location allocations</span>

### Public View

* <span class="low">(low) List all classes which are accepted</span>
