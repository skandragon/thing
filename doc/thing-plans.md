# "Thing" future plans

## Proposal

I propose that I remain the primary architect for the project, as I have
a good grasp about where to go next.  Stakeholders would be expanded first
into departments with events planned largely prior to the start of the war.
Current stakeholders also have a constant stream of requests, which must
be weighed vs adding new departments.

What I need is a server to run this on (which is being worked on) which
can run a Ruby on Rails application in an efficient manner with a database
engine (PostgreSQL and MongoDB) to store the current data and expand each
year.  Direct log-in access to this server with the ability to push changes
live without involving multiple people is a must.

Access to department heads and being able to query individual workers about
what they do and how they do it is important.  I would rather spend time
talking with people who are ultimately going to use the system rather than
those who manage those who use it, although both levels are important.

I also need developers.  I have tried to find some, but it has not been
successful to find those who follow up on the offer to assist.  Training
on how to use the system would also be important as it becomes larger, and
less computer literate users become more common place.

## Previous Work

The initial development year (Pennsic 42) focused on two primary stakeholders:
Pennsic University staff and "everyone else" as attendees.  A form to
allow easy entry of classes by instructors was created, PDF output for
end users and book publication was created.  Track leads working under
the Pennsic University role could schedule classes into locations
specifically allowed by the University staff.  End users could download
the entire class list in several formats, including PDF, Excel, CSV, and
iCal format for computers, tablets, and smart phones.

Year one focused on the University largely because of the large amount of
data they process, and because that area already has a high level of
computer use.

Year two expanded this to include additional stakeholders, including
the maintainer of the battlefield and court schedules.  This was not entirely
complete due to developer time constraints, but it did allow end users of
the combined schedule to select classes and events on their custom schedule
and to produce the various printed schedules for the Pennsic 43 book.

## Future Plans

Expanding to include additional stakeholders needs to be done carefully,
with departments and areas which are willing and able to accept the risks
associated with early adoption.  The risks of adopting new technology is
mitigated by choosing the correct development methodology.

Ideally, expansion to new stakeholders which are similar in nature to the
current stakeholders would be easier than adding additional major new
functionality, such as volunteer signup and time tracking.

Each department which wishes to use the system should be interviewed to
understand what they do now and what they would like to do.  A discussion
about what is most important would occur to discover what the minimum
viable product would be for that area.

It would be impossible to do all things each department wants, and some
departments would need to wait for future years to be included.  This is
not a short term project.

## Far Future Plans

While Pennsic is the focus of development currently, the ultimate plan
of "thing" is to become the scheduling system for all major
events within the SCA, with the ability to define an event, plan various
schedules, and produce output that is usable to as many as possible.

## Development Methodology

"Thing" is developed in an Agile manner, using current best practices for
a medium-scale project.  Test-driven development is used to help ensure
bugs do not slip by as easily and when found can be more easily corrected
with confidence.  Continuous deployment is used, which pushes small changes
into the live system rather than a large set of unrelated changes based on
time.  This gives developers the quickest feedback on changes, and also
isolates bugs to a time frame, allowing faster repairs. This Agile methodology
is the same as is used in many of the most responsive and highly regarded
web service companies such as Google, Facebook, etc.

Open source tools are used (Ruby on Rails, various Javascript and other
packages) and "thing" itself is open source.  Data is kept private to
stakeholders.

## Development Team

Currently, only one developer and architect works on the system.  We need
more developers to ensure the project is not dependent on a single person,
as well as to add additional capacity to add features and departments.
