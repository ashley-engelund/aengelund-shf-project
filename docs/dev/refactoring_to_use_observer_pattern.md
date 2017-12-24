# Refactoring managing membership status to use the Observer Pattern

We've learned a lot about the domain and have helped SHF think about and refine business rules since we started implementing all of this.
Implementing _payments_ have particularly made the models and underlying assumptions more complex. It's time to take what we've learned and think about how to refactor so that we are doing good, SOLID OO design.


#### The main function of the system is to **manage membership status.**  
 _**It must make sure that 
the membership status for every `User` in the system is always correct, based on the business rules for SHF.**_ 

---

Just to review some basics and provide some background to anyone not familiar with the terms and concepts:

#### SOLID OO Design Principles
- Single Responsibility _Each class should have a single responsbility.  coding strategy_
- Open/Closed principle _"Open" to extension (changing business requirements) but "closed" to modification (requiring lots of modifications to make that happen) a goal_
- Liskov substitution _Objects can be replaced with subclasses without affectingn the correctness of a program. abstract formula about software_
- Interface segregation _Many different interfaces are better than a few large ones (break things down into small things)_
- Dependency inversion _Be dependent on abstractions, not concretions (depend on the larger contract/responsibility, not the actual classes that might implement it) coding strategy, especially important for static languages (not Ruby)_

These are all strategies you can apply so that when change happens (and it will), you can 
reduce all the dependencies and entaglements within your code.

Another way to express these are with the more classic Software Engineering principles:
#### Software Engineering principles
- loose coupling  _things are not dependent on each other_
- high cohesion _the purpose of a component (class) should be focused and cohesive; it should have one clear, focused responsibility_
- context independent _objects are complete and independent without having to depend on lots of other objects being in specific states_
- easily composable _many, small components can be easily put together to accompish goals without having to change code_



[Robert Martin: SOLID, Agile Manifesto, 'clean' coding and architecture](https://en.wikipedia.org/wiki/Robert_C._Martin)

[Wikipedia: SOLID object oriented design](https://en.wikipedia.org/wiki/SOLID_(object-oriented_design))

[Sandi Metz: SOLID Object-Oriented Design presentation at GORUCO 2009:](https://youtu.be/v-2yFMzxqwU)  
An excellent introductory video on SOLID principles and how to put them into practice.


This is another important, Rails specific design principle:

#### Skinny Controllers
 - Controllers should be responsbile displaying the right views based on models and actions, _not_ business logic

  Reference:  Advi Grimm: Slim down hefty Rails controllers AND models, using domain model events
  https://www.rubytapas.com/2017/04/11/skinny-controller-domain-model-events/
 
 ---

## Current state

Currently, the responsbility for **knowing if the requirements for membership have been met** (_should membership be granted?_) is spread out between multiple classes:  **`PaymentsController`** and **`User`.**
This also means that the `PaymentsController` is responsible for an important piece of business domain logic.
The controller should not be responsible for this; 
it should not have to know or care about who should or should not be granted membership
 _or_ how granting membership is done, _or_  what has to happen when/if membership is granted (or revoked, for that matter). 

 
Here's a sequence diagram that shows how we currently determine if a membership should be granted and how the membership is granted.
This incorporates the changes in [PR 441: Do not grant membership for branding payment](https://github.com/AgileVentures/shf-project/pull/441)  that moves the logic into the success method of the `PaymentsController`.

![Sequence diagram for the way we currently grant membership](../wiki/payment-seq-171223.png)

Note that **both** the `PaymentsController` and `User` are  responsible for granting membership.
If the business rules change, both the `PaymentsController` class and the `User` class must be modified.

`PaymentsController` has to interact with many different domain objects. It is _highly coupled_ to many different classes.  
That means there are many dependencies (entanglements).
It should not be responsible for implementing business logic.


Additionally, the `User` class has many, many responsibilities.  Among them, the `User` class:
  - must determine the next membership number that should be used in the system
  - must calculate the end of the current membership term, which depends on knowing the specific type of payment
  - must know that mail should be sent out when membership is granted, and which email to send
  - if a membership term has expired or not, which depends on knowing the specific type of payment 
  - if a membership payment can be made
  - when the next membership payment is due, which depends on knowing about the type of payment that a 'membership fee' is
  
The `User` class clearly does not have a single responsbility.  We need to refactor it and put those responsibilities elsewhere.
A `User` class should _respond_ and perhaps change its internal state based on essages it receives from other things in the system.

## Refactoring to be more SOLID


When we need to respond to changing business requirments (not "if," but _when_), we should have one place (interface or class) where we make changes. (This is a core concept in _agile_ software development.)
The rest of the system should not have to be modified (**Open/Closed principle**).

In order to accomplish this, we need to have minimal coupling ( = minimal dependencies or 'entanglements'). 

We can be much more SOLID by setting up one class that is responsible for knowing if membership requirements have been satisfied, and another class that is responsible for granting membership. (= **Single Responsibility Principle**)

It's easy to reduce coupling (dependencies/entanglements)by having a class **observe** the state of domain objects and see if and when membership needs to be checked and possibly updated.
Other classes can go on about their own business (_responsibilities_), secure in the knowledge that if membership needs to be updated, another class is watching out for that and will do whatever needs to be done.
In other words, other classes do not share that responsibility (they should be focused on their own single responsbility).
Nor are they invovled (entangled, coupled, or required depdendencies) in figuring out membership requirements or what has to happen when membership is granted.

The **Observer pattern** is a fundamental and common pattern in software and is easy to implement in Ruby with the standard library **Observable** module.

Putting it together, here is what I did when I refactored:

- created a class that has the single responsibility of knowing if a `User` meets the all of the 
requirements for being a member: **`MembershipRequirements`**
- created a class that has the single responsibility of doing what needs 
to be done when membership is granted: **`MembershipStatusUpdater`**  (In my code, I have also included the responsibility for revoking membership.  It could easily be argued that this should be in a separate class.)
- removed those responsiblities from the `User` and `PaymentsController` classes
- used the **Observer pattern** to reduce dependencies (coupling) between those classes when membership is granted.

Here's the sequence diagram with the refactored code:

![sequence diagram with code refactored to use the Observer pattern](../wiki/payment-seq-observer-171223.png)  
  


The sequence diagram makes it clear that the `PaymentsControler`  now does much less.
 When the payment has been made successfully, the `PaymentsControler` now just makes sure that the `payment` sends the `successfully_made` message.  The `PaymentsControler` does not need to know (is not coupled with or entangled with) what that 'means' or what other objects/classes that might involve.
 
 
 The sequence diagram also helps to show that the process for updating membershipe (checking to see if membership requirements are being met and grantin membership) is much more encapsulated. 
 Far fewer dependencies are invovled. ( = lower coupling)
 
 
 As should happen with a refactoring, all tests that are not unit tests should still pass without being altered.  For this project, that means that all cucumber tests should still pass without any changes to the `.feature` files. _(They do pass.)_
 
 The only change that was needed to the cucumber files was to alter one step definition: `And(/^I complete the payment$/) do` The lines that explicitly forced that user to grant membership were removed (commented out).  The membership status is now updated automatically ('naturally') by the system via the observer pattern.
 Since step definitions stand in for a certain amount of implementation, it is reasonable that they might have to be changed when code is refactored.  In this case, the change to the step clearly reflects that a `User` no longer has the responsibility for granting membership.  
 

### Disclaimers and notes about the code:
It took me longer to write this up than it did to write the code, which is a testement to the power of the Observer pattern.

- There is surely clean up and further refactoring that can be done.  I did write specifications and tests, but did not double-check to ensure that I have covered all possibilities or needed scenarios.
- I used Singletons for the Updaters, but that's not necessary; using class methods is also a valid approach.
- I orginially started recording my thoughts in the doc comment for the MembershipStatusUpdater class; I didn't clean that up.
- I put the Updater and MembershipRequirements classes under the `app/model` directory.  They could certainly be `services` and go into that directory. I just started with them there out of habit and didn't want to spend too much time on that, knowing this is an exploratory spike.
- I commented out some specs instead of removing them when I refactored to (hopefully) make things clear and to show that when a specification is big, that's a smell that the class has too many responsibilities.
- I did some 'clean up' with the Payments state: I used constants to help hide the implementation (the mapping to the Hips values)



