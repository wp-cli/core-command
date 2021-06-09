Feature: Retrieve a list of available releases

  Scenario: Check for a list of all available releases
    When I run `wp core release`
    Then STDOUT should be a table containing rows:
      | version | download | mysql_version | php_version |
    And STDERR should be empty

  Scenario: Check a list of releases in the 4 branch
    When I run `wp core release 4 --field=download`
    And STDOUT should contain:
      """
      wordpress-4.
      """
    And STDOUT should not contain:
      """
      wordpress-5.
      """
    And STDOUT should not contain:
      """
      wordpress-3.
      """
    And STDERR should be empty

  Scenario: Check a list of releases in the 4.9 branch
    When I run `wp core release 4.9 --field=download`
    And STDOUT should contain:
      """
      wordpress-4.9.
      """
    And STDOUT should not contain:
      """
      wordpress-5.
      """
    And STDOUT should not contain:
      """
      wordpress-3.
      """
    And STDOUT should not contain:
      """
      wordpress-4.8.
      """
    And STDERR should be empty

  Scenario: Abort when trying to use a patch constraint
    When I try `wp core release 4.9.9`
    And STDOUT should be empty
    And STDERR should contain:
      """
      Only major or minor versions are supported as constraints.
      """

  Scenario: Abort when trying to use a pre-release constraint
    When I try `wp core release 4.9.9-alpha`
    And STDOUT should be empty
    And STDERR should contain:
      """
      Only major or minor versions are supported as constraints.
      """

  Scenario: Abort when trying to use a build constraint
    When I try `wp core release 4.9.9-alpha-12345`
    And STDOUT should be empty
    And STDERR should contain:
      """
      Only major or minor versions are supported as constraints.
      """

  Scenario: Abort when the version constraint could not be parsed
    When I try `wp core release some-version`
    And STDOUT should be empty
    And STDERR should contain:
      """
      Unable to parse version string data (some-version).
      """

  Scenario: Retrieve only the latest version
    When I run `wp core release 4 --field=download`
    And STDOUT should contain:
      """
      wordpress-4.9.
      """
    And STDOUT should contain:
      """
      wordpress-4.8.
      """
    And STDOUT should contain:
      """
      wordpress-4.7.
      """
    And STDERR should be empty

    When I run `wp core release 4 --field=download --latest`
    And STDOUT should contain:
      """
      wordpress-4.9.
      """
    And STDOUT should not contain:
      """
      wordpress-4.8.
      """
    And STDOUT should not contain:
      """
      wordpress-4.7.
      """
    And STDERR should be empty
