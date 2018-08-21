#!/bin/bash
cat <<-YAML
steps:
-
  name: "Stress Test"
  command: ".ci/scripts/test-stress"
  retry:
    automatic: true
  artifact_paths:
    - ".ci/results/xcodebuild.log"
    - ".ci/xcodebuild-data/Build/Logs/Test/*.xcovreport"    
  agents:
    queue: "stress-tests"
    xcode: "$XCODE"
-
  name: "macOS"
  command: ".ci/scripts/test-macos"
  retry:
    automatic: true
  artifact_paths:
    - ".ci/results/xcodebuild.log"
    - ".ci/xcodebuild-data/Build/Logs/Test/*.xcovreport"    
  agents:
    xcode: "$XCODE"
-
  name: "iOS"
  command: ".ci/scripts/test-ios"
  retry:
    automatic: true
  artifact_paths:
    - ".ci/results/xcodebuild.log"
    - ".ci/xcodebuild-data/Build/Logs/Test/*.xcovreport"    
  agents:
    queue: "iOS-Simulator"
    xcode: "$XCODE"
-
  name: "tvOS"
  command: ".ci/scripts/test-tvos"
  retry:
    automatic: true
  artifact_paths:
    - ".ci/results/xcodebuild.log"
    - ".ci/xcodebuild-data/Build/Logs/Test/*.xcovreport"
  agents:
    queue: "iOS-Simulator"
    xcode: "$XCODE"
    
- wait

- 
  name: "Test CocoaPods Integration"
  command: ".ci/scripts/test-cocoapods"  
  agents:
    queue: "iOS-Simulator"
    xcode: "$XCODE"

- wait

-
  name: "Slather"
  command: "slather --scheme iOS"
  artifact_paths:
    - ".ci/results/coverage"
    - ".ci/xcodebuild-data/Build/Logs/Test/*.xcovreport"

-
  command: "Report Code Climate Test Coverage"
  label: ":codeclimate: Report Coverage"
  plugins:
    jobready/codeclimate-test-reporter#v2.0:
      artifacts: ".ci/results/coverage"
      input_type: "cobertura"


YAML

if [[ "$BUILDKITE_BUILD_CREATOR" != "Daniel Thorpe" ]]; then
cat <<-YAML

- block: "Docs"

YAML
fi

cat <<-YAML

- 
  name: ":aws: Generate Docs"
  trigger: "procedurekit-documentation"
  build:
    message: "Generating documentation for ProcedureKit"
    commit: "HEAD"
    branch: "master"
    env:
      PROCEDUREKIT_HASH: "$COMMIT"
      PROCEDUREKIT_BRANCH: "$BRANCH"
YAML