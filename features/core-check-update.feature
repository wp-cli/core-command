Feature: Check for more recent versions

  # This test downgrades to an older WordPress version, but the SQLite plugin requires 6.0+
  @require-mysql
  Scenario: Check for update via Version Check API
    Given a WP install
    And I try `wp theme install twentytwenty --activate`

    When I run `wp core download --version=5.8 --force`
    Then STDOUT should not be empty

    When I run `wp core check-update`
    Then STDOUT should be a table containing rows:
      | version                 | update_type | package_url                                                                             |
      | {WP_VERSION-latest}     | major       | https://downloads.wordpress.org/release/wordpress-{WP_VERSION-latest}.zip               |
      | {WP_VERSION-5.8-latest} | minor       | https://downloads.wordpress.org/release/wordpress-{WP_VERSION-5.8-latest}-partial-0.zip |

    When I run `wp core check-update --format=count`
    Then STDOUT should be:
      """
      2
      """

    When I run `wp core check-update --major`
    Then STDOUT should be a table containing rows:
      | version             | update_type | package_url                                                               |
      | {WP_VERSION-latest} | major       | https://downloads.wordpress.org/release/wordpress-{WP_VERSION-latest}.zip |

    When I run `wp core check-update --major --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp core check-update --minor`
    Then STDOUT should be a table containing rows:
      | version                 | update_type | package_url                                                                             |
      | {WP_VERSION-5.8-latest} | minor       | https://downloads.wordpress.org/release/wordpress-{WP_VERSION-5.8-latest}-partial-0.zip |

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
