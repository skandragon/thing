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

* (done)  signup
* (done) request to be a teacher form
* (done) "request to teach a class" form (that is, class submission)

### Administration

* (low) Send a password reset token to a user
* (high) Allow editing of all aspects, other than password, for a user
* (high) generate a list of email addresses for users who are instructors
* (high) generate a list of email addresses for users who are tract leads

### PU Coordinator

* (high) Assign a user to a tract lead position


### Email Notifications

* (medium) Send email to instructors when their class status changes
* (medium) Send email to tract leads when a class is assigned to their area
* (medium) Send email to PU admin when a new class is added
* (low) Periodic email reminders
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

* (high) Enable coordinators' editing of classes assigned to their tract
   * (high) A simple assign-to-location-and-time page
* (high) listing of classes which need to be accepted
* (high) listing of classes which need to be scheduled
* (high) listing of all classes in a tract, by day, location, topic
* (high) some sort of display showing location allocations

### Public View

* (low) List all classes which are accepted
