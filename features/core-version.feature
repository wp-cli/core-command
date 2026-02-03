Feature: Find version for WordPress install

  Scenario: Verify core version
    Given a WP install
    And I run `wp core download --version=4.4.2 --force`

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

  # This test downgrades to an older WordPress version, but the SQLite plugin requires 6.0+
  @require-mysql
  Scenario: Verify actual database version shows correct values
    Given a WP install
    And I run `wp core download --version=6.6 --force`
    And I run `wp option update db_version 45805`

    # Without --actual, should show expected version from version.php
    When I run `wp core version --extra`
    Then STDOUT should contain:
      """
      Database revision: 47018
      """

    # With --actual, should show actual database version
    When I run `wp core version --extra --actual`
    Then STDOUT should contain:
      """
      Database revision: 45805
      """

  # This test downgrades to an older WordPress version, but the SQLite plugin requires 6.0+
  @require-mysql
  Scenario: Verify actual database version in multisite subsite
    Given a WP multisite install
    And I run `wp core download --version=6.6 --force`
    And I run `wp option update db_version 47018`
    And I run `wp site create --slug=subsite --porcelain`
    And save STDOUT as {SUBSITE_ID}
    And I run `wp option update db_version 45805 --url=example.com/subsite`

    # Main site shows expected version from version.php without --actual
    When I run `wp core version --extra`
    Then STDOUT should contain:
      """
      Database revision: 47018
      """

    # Main site shows actual database version with --actual
    When I run `wp core version --extra --actual`
    Then STDOUT should contain:
      """
      Database revision: 47018
      """

    # Subsite shows expected version from version.php without --actual
    When I run `wp core version --extra --url=example.com/subsite`
    Then STDOUT should contain:
      """
      Database revision: 47018
      """

    # Subsite shows its own actual database version with --actual
    When I run `wp core version --extra --actual --url=example.com/subsite`
    Then STDOUT should contain:
      """
      Database revision: 45805
      """

  Scenario: Error when using --actual without --extra
    Given a WP install

    When I try `wp core version --actual`
    Then STDERR should contain:
      """
      Error: The --actual flag can only be used with --extra.
      """
    And the return code should be 1

