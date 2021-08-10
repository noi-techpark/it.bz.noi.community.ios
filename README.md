# it.bz.noi.community.ios
NOI Community App for iOS

> TODO Describe what this App provides

*Table of Contents*
- [it.bz.noi.community.ios](#itbznoicommunityios)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Source code](#source-code)
    - [Configure the project](#configure-the-project)
  - [Running tests](#running-tests)
  - [Deployment](#deployment)
  - [Information](#information)
    - [Support](#support)
    - [Contributing](#contributing)
    - [Documentation](#documentation)
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

> TODO A detailed description about how the application must be deployed.

## Information

### Support

For support, please contact [help@opendatahub.bz.it](mailto:help@opendatahub.bz.it).

### Contributing

If you'd like to contribute, please follow the following instructions:

- Fork the repository.

- Checkout a topic branch from the `development` branch.

- Make sure the tests are passing.

- Create a pull request against the `development` branch.

### Documentation

More documentation can be found at 

> TODO

### License

The code in this project is licensed under the GNU GENERAL PUBLIC LICENSE 3.0 or later license.
See the LICENSE file for more information.
