Feature: Find version for WordPress install

  Scenario: Verify core version
    Given a WP install
    # May produce a warning if the checksums for the version being replaced cannot be retrieved, e.g. for a development build.
    And I try `wp core download --version=4.4.2 --force`
    And the return code should be 0

    When I run `wp core version`
    Then STDOUT should be:
      """
      4.4.2
      """

    When I run `wp core version --extra`
    Then STDOUT should be:
      """
      WordPress version: 4.4.2
      Database revision: 35700
      TinyMCE version:   4.208 (4208-20151113)
      Package language:  en_US
      """

  Scenario: Installing WordPress for a non-default locale and verify core extended version information.
    Given an empty directory
    And an empty cache

    When I run `wp core download --version=4.4.2 --locale=de_DE`
    Then STDOUT should contain:
      """
      Success: WordPress downloaded.
      """

    When I run `wp core version --extra`
    Then STDOUT should be:
      """
      WordPress version: 4.4.2
      Database revision: 35700
      TinyMCE version:   4.208 (4208-20151113)
      Package language:  de_DE
      """
