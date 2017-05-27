Feature: Find latest version of WordPress available

  Scenario: Return latest version.
    When I run `wp core latest_version`
    Then STDOUT should be:
      """
      {WP_VERSION-latest}
      """

    When I run `wp core latest_version 4.3`
    Then STDOUT should be:
      """
      {WP_VERSION-4.3-latest}
      """

    When I run `wp core latest_version 4`
    Then STDOUT should be:
      """
      {WP_VERSION-latest}
      """

    # Earliest version it works for.
    When I run `wp core latest_version 3.7`
    Then STDOUT should be:
      """
      {WP_VERSION-3.7-latest}
      """

    # Synonym ignored.
    When I run `wp core latest_version latest`
    Then STDOUT should be:
      """
      {WP_VERSION-latest}
      """

  Scenario: Return trunk version.
    When I run `wp core latest_version trunk`
    Then STDOUT should be a version string > {WP_VERSION-latest}

  Scenario: Specifying versions earlier than 3.7 is not supported.
    When I try `wp core latest_version 3.6`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Failed to match version.
      """
    And STDOUT should be empty

  Scenario: Specifying a full version is not supported.
    When I try `wp core latest_version 4.0.4`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Invalid version.
      """
    And STDOUT should be empty

  Scenario: Specifying an invalid version.
    When I try `wp core latest_version 1.2.3.4`
    Then the return code should be 1
    And STDERR should contain:
      """
      Error: Invalid version.
      """
    And STDOUT should be empty
