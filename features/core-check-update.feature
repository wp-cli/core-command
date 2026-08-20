Feature: Check for more recent versions

  # This test downgrades to an older WordPress version, but the SQLite plugin requires 6.0+
  @require-mysql
  Scenario: Check for update via Version Check API
    Given a WP install
    And I try `wp theme install twentytwenty --activate`
    # The Version Check API only offers in-branch (minor) updates to a subset of
    # sites, bucketed by the site URL, so the response is mocked to stay stable.
    And that HTTP requests to https://api.wordpress.org/core/version-check/1.7/ will respond with:
      """
      HTTP/1.1 200 OK
      Content-Type: application/json

      {"offers":[{"response":"upgrade","download":"https://downloads.wordpress.org/release/wordpress-6.0.zip","locale":"en_US","packages":{"full":"https://downloads.wordpress.org/release/wordpress-6.0.zip","no_content":false,"new_bundled":false,"partial":false,"rollback":false},"current":"6.0","version":"6.0","php_version":"5.6.20","mysql_version":"5.0"},{"response":"autoupdate","download":"https://downloads.wordpress.org/release/wordpress-5.8.1.zip","locale":"en_US","packages":{"full":"https://downloads.wordpress.org/release/wordpress-5.8.1.zip","no_content":false,"new_bundled":false,"partial":"https://downloads.wordpress.org/release/wordpress-5.8.1-partial-0.zip","rollback":false},"current":"5.8.1","version":"5.8.1","php_version":"5.6.20","mysql_version":"5.0"}]}
      """

    When I run `wp core download --version=5.8 --force`
    Then STDOUT should not be empty

    When I run `wp core check-update --format=csv`
    Then STDOUT should be:
      """
      version,update_type,package_url
      5.8.1,minor,https://downloads.wordpress.org/release/wordpress-5.8.1-partial-0.zip
      6.0,major,https://downloads.wordpress.org/release/wordpress-6.0.zip
      """

    When I run `wp core check-update --format=count`
    Then STDOUT should be:
      """
      2
      """

    When I run `wp core check-update --major --format=csv`
    Then STDOUT should be:
      """
      version,update_type,package_url
      6.0,major,https://downloads.wordpress.org/release/wordpress-6.0.zip
      """

    When I run `wp core check-update --major --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp core check-update --minor --format=csv`
    Then STDOUT should be:
      """
      version,update_type,package_url
      5.8.1,minor,https://downloads.wordpress.org/release/wordpress-5.8.1-partial-0.zip
      """

    When I run `wp core check-update --minor --format=count`
    Then STDOUT should be:
      """
      1
      """

  Scenario: Check output of check update in different formats (no updates available)
    Given a WP install
    And a setup.php file:
      """
      <?php
      global $wp_version;

      $obj = new stdClass;
      $obj->updates = [];
      $obj->last_checked = strtotime( '1 January 2099' );
      $obj->version_checked = $wp_version;
      $obj->translations = [];
      set_site_transient( 'update_core', $obj );
      """
    And I run `wp eval-file setup.php`

    When I run `wp core check-update`
    Then STDOUT should be:
      """
      Success: WordPress is at the latest version.
      """

    When I run `wp core check-update --format=json`
    Then STDOUT should be:
      """
      []
      """

    When I run `wp core check-update --format=yaml`
    Then STDOUT should be:
      """
      ---
      """

  Scenario: Check update shows warning when version check API fails
    Given a WP install
    And that HTTP requests to https://api.wordpress.org/core/version-check/1.7/ will respond with:
      """
      HTTP/1.1 500 Internal Server Error
      Content-Type: text/plain

      <Error body>
      """

    When I try `wp core check-update --force-check`
    Then STDERR should contain:
      """
      Warning: Failed to check for updates
      """
