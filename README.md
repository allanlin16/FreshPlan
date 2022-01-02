# FreshPlan
meet-up app that plans when you guys want to meet.

## Requirements
1. Cocoapods
1. RVM (Ruby) but this should be pre-default installed on a mac os

## Setting up the Project

This project uses a MVMM architecture, along with the usage of RxSwift. This allows us to have clean and beautiful code. To begin, do the following steps:

1. Install `bundler` by doing `gem install bundler`
1. First, on the project directory, do `bundle install` to get the gems.
1. Type in `bundle exec pod install` to get the pods.
  1. Note: Any time a podfile changes, you'll need to do pod install.
1. Open up the `.xcworkspace` file, not `.xcodeproj`.
