# NOI Community App for iOS

The NOI-Community App is your information and communication channel to keep in
touch with the growing innovation district of NOI Techpark and its members. Are
you looking for a specific company that is working here? Do you need to book a
room for your next team meeting? Or do you simply want to know today's choice of
dishes in the Community Bar? From now on, you can find all that in one
application. More tools to come, so stay tuned!

We have also an [App for
Android](https://github.com/noi-techpark/it.bz.noi.community.android).

**Table of Contents**
- [NOI Community App for iOS](#noi-community-app-for-ios)
	- [Getting started](#getting-started)
		- [Prerequisites](#prerequisites)
		- [Source code](#source-code)
		- [Configure the project](#configure-the-project)
	- [Running tests](#running-tests)
	- [Deployment](#deployment)
	- [Information](#information)
		- [Support](#support)
		- [Contributing](#contributing)
		- [License](#license)

## Getting started

These instructions will get you a copy of the project up and running
on your local machine for development and testing purposes.

### Prerequisites

To build the project, the following prerequisites must be met:

1. Xcode 12 (downloadable from https://developer.apple.com/xcode/resources/)
2. Be a member of NOI SPA Apple Developer Team (if you want to run the app and tests on your device)
   (write a mail to [help@opendatahub.bz.it](mailto:help@opendatahub.bz.it), if you need access)

### Source code

Get a copy of the repository:

```bash
git clone git@github.com:noi-techpark/it.bz.noi.community.ios.git
```

### Configure the project

No configuration is needed.

## Running tests

The unit tests can be executed on a device by replacing `<device_name>` with
your device name with the following command:

```bash
xcodebuild  -project NOICommunity.xcodeproj \
-scheme NOICommunity \
-destination 'platform=iOS,name=<device_name>' \
clean test
```

or on an iOS simulator by replacing `<simulator_name>` with a simulator name
with the following command:

```bash
xcodebuild  -project NOICommunity.xcodeproj \
-scheme NOICommunity \
-destination 'platform=iOS Simulator,OS=14.5,name=<simulator_name>' \
clean test
```

When you install Xcode it comes with default simulators, one per each supported
device and its simulator name is the device model; e.g. "iPhone 12".

For some examples see [.github/workflows].


## Deployment

We deploy the application with Github Actions to a Test Track, if someone pushes
to the `development` branch. See
[.github/workflows/main.yml](.github/workflows/main.yml) and [Continuous
Deployment for iOS
Apps](https://github.com/noi-techpark/odh-docs/wiki/Continuous-Deployment-for-iOS-Apps)
for details...

## Information

### Support

For support, please contact [help@opendatahub.bz.it](mailto:help@opendatahub.bz.it).

### Contributing

If you'd like to contribute, please follow our [Getting
Started](https://github.com/noi-techpark/odh-docs/wiki/Contributor-Guidelines:-Getting-started)
instructions.

### License

The code in this project is licensed under the GNU GENERAL PUBLIC LICENSE 3.0 or
later license. See the LICENSE file for more information.
