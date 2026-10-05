# Digital Pet – In-Class Activity 07

## Team Members

- Maya Cockerham
- Liban Mohamed

## Project Overview

This project is a Flutter Digital Pet application created by Maya Cockerham and Liban Mohamed. The goal of the app is to take care of a virtual pet while managing its happiness, hunger, and energy. The pet's mood changes based on its happiness level, and the user can interact with the pet using different care actions and activities.

## Core Features

- Editable pet name
- Happiness meter from 0–100
- Hunger meter from 0–100
- Readable pet mood
- Pet image changes tint depending on mood
- Feed button
- Play button
- Reset button
- Hunger automatically increases every 30 seconds
- Win and loss conditions
- Care buttons are disabled after a win or loss until the pet is reset
- Values are kept between 0 and 100

## Mood System

The pet has three different moods based on happiness:

- Happy: Happiness is greater than 70
- Neutral: Happiness is between 30 and 70
- Unhappy: Happiness is below 30

The pet image uses `ColorFiltered` with `BlendMode.modulate` to visually show the mood. Green represents a happy mood, yellow represents a neutral mood, and red represents an unhappy mood.

The mood is also displayed as text so that color is not the only way the user can tell how the pet is feeling.

## Timer and Game Rules

The hunger meter increases by 5 every 30 seconds.

If hunger would increase above 100, hunger stays at 100 and happiness decreases by 20.

The player wins when happiness stays above 80 continuously for three minutes.

The player loses when hunger reaches 100 and happiness is 10 or lower.

The Reset Pet button restores the pet to its starting values and restarts the hunger timer.

## Advanced Feature 1 – Energy System

We added an Energy System to make the Digital Pet more interactive.

The pet starts with an energy level and different actions affect its energy. Playing with the pet uses energy. If the pet does not have enough energy, the app prevents the action and displays a message telling the user that the pet needs to rest.

Resting allows the pet to regain energy.

The energy value is kept between 0 and 100.

## Advanced Feature 2 – Activity Selection

We also added an Activities section with Run and Sleep.

### Run

Running affects several pet values:

- Increases happiness
- Increases hunger
- Decreases energy

If the pet does not have enough energy, the Run activity cannot be completed and the user receives a message.

### Sleep

Sleeping also affects multiple values:

- Restores energy
- Slightly increases happiness
- Increases hunger

Adding activities made the different pet needs work together instead of each meter operating independently.

## State Management

The application uses a `StatefulWidget` and `setState()` to update the user interface whenever the pet's state changes.

The main state values include:

- Pet name
- Happiness
- Hunger
- Energy
- Win status
- Game-over status

Timers are used for the automatic hunger increase and the three-minute win condition.

The timers are cancelled when they are no longer needed, and the `TextEditingController` used for the pet name is disposed of properly.

## Testing

We manually tested the following parts of the application:

- Changing the pet's name
- Feeding the pet
- Playing with the pet
- Resting
- Running
- Sleeping
- Happiness staying between 0 and 100
- Hunger staying between 0 and 100
- Energy staying between 0 and 100
- Mood text changing with happiness
- Pet color changing with happiness
- Reset restoring the starting values
- Hunger automatically increasing over time
- Buttons responding correctly when the pet has low energy

We also checked the Flutter project using:

`flutter analyze`

Final result:

`No issues found!`

We successfully created the release APK using:

`flutter build apk --release`

## Pet Asset

The project uses one pet PNG located at:

`assets/pet.png`

The image is registered in `pubspec.yaml` and displayed in the application using `Image.asset()` and `ColorFiltered`.

### Asset Attribution

Pet image source/license: Add the original source and license information here before final submission.

## Team Contributions

### Maya Cockerham

- Worked on the Digital Pet interface and overall app layout
- Helped implement the happiness, hunger, and energy systems
- Worked on the pet mood and image behavior
- Helped implement the care actions and activity features
- Tested the application and verified app behavior
- Helped debug errors and prepare the final release build
- Helped prepare the GitHub repository for submission

### Liban Mohamed

- Collaborated on the Digital Pet application
- Helped develop and review the application features
- Worked on pet interaction and state behavior
- Helped test the application's functionality
- Assisted with debugging and completing the project
- Helped review the final application for submission

## Collaboration

Maya Cockerham and Liban Mohamed worked together on the Digital Pet project. We collaborated on the design, functionality, testing, and debugging of the application. We reviewed the project together to make sure the required features worked correctly and that the application was ready for submission.

## GitHub Repository

https://github.com/mcockerham26/digital_pet_inclass07