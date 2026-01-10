Feature: Update WordPress core

  # This test downgrades to an older WordPress version, but the SQLite plugin requires 6.4+
  @require-mysql
  Scenario: Update from a ZIP file
    Given a WP install
    And I try `wp theme install twentytwenty --activate`

    When I run `wp core download --version=6.2 --force`
    Then STDOUT should not be empty

    When I try `wp eval 'echo $GLOBALS["wp_version"];'`
    Then STDOUT should be:
      """
      6.2
      """

    When I run `wget http://wordpress.org/wordpress-6.2.zip --quiet`
    And I run `wp core update wordpress-6.2.zip`
    Then STDOUT should be:
      """
      Starting update...
      Unpacking the update...
      Success: WordPress updated successfully.
      """

    When I try `wp eval 'echo $GLOBALS["wp_version"];'`
    Then STDOUT should be:
      """
      6.2
      """

  @require-php-7.0
  Scenario: Output in JSON format
    Given a WP install
    And I try `wp theme install twentytwenty --activate`

    When I run `wp core download --version=6.6 --force`
    Then STDOUT should not be empty

    When I run `wp eval 'echo $GLOBALS["wp_version"];'`
    Then STDOUT should be:
      """
      6.6
      """

    When I run `wget http://wordpress.org/wordpress-6.8.zip --quiet`
    And I run `wp core update wordpress-6.8.zip --format=json`
    Then STDOUT should be:
      """
      [{"name":"core","old_version":"6.6","new_version":"6.8","status":"Updated"}]
      """

  @require-php-7.0
  Scenario: Output in CSV format
    Given a WP install
    And I try `wp theme install twentytwenty --activate`

    When I run `wp core download --version=6.6 --force`
    Then STDOUT should not be empty

    When I run `wp eval 'echo $GLOBALS["wp_version"];'`
    Then STDOUT should be:
      """
      6.6
      """

    When I run `wget http://wordpress.org/wordpress-6.8.zip --quiet`
    And I run `wp core update wordpress-6.8.zip --format=csv`
    Then STDOUT should be:
      """
      name,old_version,new_version,status
      core,6.6,6.8,Updated
      """

  @require-php-7.0
  Scenario: Output in table format
    Given a WP install
    And I try `wp theme install twentytwenty --activate`

    When I run `wp core download --version=6.6 --force`
    Then STDOUT should not be empty

    When I run `wp eval 'echo $GLOBALS["wp_version"];'`
    Then STDOUT should be:
      """
      6.6
      """

    When I run `wget http://wordpress.org/wordpress-6.8.zip --quiet`
    And I run `wp core update wordpress-6.8.zip --format=table`
    Then STDOUT should end with a table containing rows:
      | name | old_version | new_version | status  |
      | core | 6.6         | 6.8         | Updated |

  # This test downgrades to an older WordPress version, but the SQLite plugin requires 6.4+
  @require-mysql
  Scenario: Update to the latest minor release (PHP 7.2 compatible with WP >= 4.9)
    Given a WP install
    And I try `wp theme install twentytwenty --activate`

    When I run `wp core download --version=6.2.5 --force`
    Then STDOUT should contain:
      """
      Success: WordPress downloaded.
      """

    # This version of WP throws a PHP notice
    When I try `wp core update --minor`
    Then STDOUT should contain:
      """
      Updating to version {WP_VERSION-6.2-latest}
      """
    And STDOUT should contain:
      """
      Success: WordPress updated successfully.
      """
    And the return code should be 0

    When I run `wp core update --minor`
    Then STDOUT should be:
      """
      Success: WordPress is at the latest minor release.
      """

    When I run `wp core version`
    Then STDOUT should be:
      """
      {WP_VERSION-6.2-latest}
      """

  # This test downgrades to an older WordPress version, but the SQLite plugin requires 6.4+
  @require-mysql
  Scenario: Core update from cache
    Given a WP install
    And I try `wp theme install twentytwenty --activate`
    And an empty cache

    When I run `wp core update --version=6.2.5 --force`
    Then STDOUT should not contain:
      """
      Using cached file
      """
    And STDOUT should contain:
      """
      Downloading
      """

    When I run `wp core update --version=6.0 --force`
    Then STDOUT should not be empty

    When I run `wp core update --version=6.2.5 --force`
    Then STDOUT should contain:
      """
      Using cached file '{SUITE_CACHE_DIR}/core/wordpress-6.2.5-en_US.zip'...
      """
    And STDOUT should not contain:
      """
      Downloading
      """

  @require-php-7.0
  Scenario: Don't run update when up-to-date
    Given a WP install
    And I run `wp core update`

    When I run `wp core update`
    Then STDOUT should contain:
      """
      WordPress is up to date
      """
    And STDOUT should not contain:
      """
      Updating
      """

    When I run `wp core update --force`
    Then STDOUT should contain:
      """
      Updating
      """

  Scenario: Ensure cached partial upgrades aren't used in full upgrade
    Given a WP install
    And I try `wp theme install twentytwenty --activate`
    And an empty cache
    And a wp-content/mu-plugins/upgrade-override.php file:
      """
      <?php
      add_filter( 'pre_site_transient_update_core', function(){
        return (object) array(
          'updates' => array(
              (object) array(
                'response' => 'autoupdate',
                'download' => 'https://downloads.wordpress.org/release/wordpress-6.5.5.zip',
                'locale' => 'en_US',
                'packages' => (object) array(
                  'full' => 'https://downloads.wordpress.org/release/wordpress-6.5.5.zip',
                  'no_content' => 'https://downloads.wordpress.org/release/wordpress-6.5.5-no-content.zip',
                  'new_bundled' => 'https://downloads.wordpress.org/release/wordpress-6.5.5-new-bundled.zip',
                  'partial' => 'https://downloads.wordpress.org/release/wordpress-6.5.5-partial-1.zip',
                  'rollback' => 'https://downloads.wordpress.org/release/wordpress-6.5.5-rollback-1.zip',
                ),
                'current' => '6.5.5',
                'version' => '6.5.5',
                'php_version' => '8.2.1',
                'mysql_version' => '5.0',
                'new_bundled' => '6.4',
                'partial_version' => '6.5.2',
                'support_email' => 'updatehelp42@wordpress.org',
                'new_files' => '',
             ),
          ),
          'version_checked' => '6.5.5', // Needed to avoid PHP notice in `wp_version_check()`.
        );
      });
      """

    When I run `wp core download --version=6.5.2 --force`
    And I run `wp core update`
    Then STDOUT should contain:
      """
      Success: WordPress updated successfully.
      """
    And the {SUITE_CACHE_DIR}/core directory should contain:
      """
      wordpress-6.5.2-en_US.tar.gz
      wordpress-6.5.5-partial-1-en_US.zip
      """

    # Allow for implicit nullable warnings produced by Requests.
    When I try `wp core download --version=6.4.1 --force`
    And I run `wp core update`
    Then STDOUT should contain:
      """
      Success: WordPress updated successfully.
      """

    # Allow for warnings to be produced.
    When I try `wp core verify-checksums`
    Then STDOUT should be:
      """
      Success: WordPress installation verifies against checksums.
      """
    And the {SUITE_CACHE_DIR}/core directory should contain:
      """
      wordpress-6.4.1-en_US.tar.gz
      wordpress-6.5.2-en_US.tar.gz
      wordpress-6.5.5-no-content-en_US.zip
      wordpress-6.5.5-partial-1-en_US.zip
      """

  # This test downgrades to an older WordPress version, but the SQLite plugin requires 6.0+
  @less-than-php-7.3 @require-mysql
  Scenario: Make sure files are cleaned up
    Given a WP install
    And I try `wp theme install twentytwenty --activate`

    When I run `wp core update --version=4.4 --force`
    Then the wp-includes/rest-api.php file should exist
    And the wp-includes/class-wp-comment.php file should exist
    And STDOUT should not contain:
      """
      File removed: wp-content
      """

    When I run `wp core update --version=4.3.2 --force`
    Then the wp-includes/rest-api.php file should not exist
    And the wp-includes/class-wp-comment.php file should not exist
    And STDOUT should contain:
      """
      File removed: wp-includes/class-walker-comment.php
      File removed: wp-includes/class-wp-network.php
      File removed: wp-includes/embed-template.php
      File removed: wp-includes/class-wp-comment.php
      File removed: wp-includes/class-wp-http-response.php
      File removed: wp-includes/class-walker-category-dropdown.php
      File removed: wp-includes/rest-api.php
      """
    And STDOUT should not contain:
      """
      File removed: wp-content
      """

    When I run `wp option add str_opt 'bar'`
    Then STDOUT should not be empty
    When I run `wp post create --post_title='Test post' --porcelain`
    Then STDOUT should be a number

  # This test downgrades to an older WordPress version, but the SQLite plugin requires 6.4+
  @require-mysql
  Scenario: Make sure files are cleaned up with mixed case
    Given a WP install
    And I try `wp theme install twentytwenty --activate`

    When I run `wp core update --version=5.8 --force`
    Then the wp-includes/Requests/Transport/cURL.php file should exist
    And the wp-includes/Requests/Exception/Transport/cURL.php file should exist
    And the wp-includes/Requests/Exception/HTTP/502.php file should exist
    And the wp-includes/Requests/IRI.php file should exist
    And the wp-includes/Requests/src/Transport/Curl.php file should not exist
    And the wp-includes/Requests/src/Exception/Transport/Curl.php file should not exist
    And the wp-includes/Requests/src/Exception/Http/Status502.php file should not exist
    And the wp-includes/Requests/src/Iri.php file should not exist
    And STDOUT should contain:
      """
      Cleaning up files...
      """
    And STDOUT should contain:
      """
      Success: WordPress updated successfully.
      """

    When I run `wp core update --version=6.2 --force`
    Then the wp-includes/Requests/Transport/cURL.php file should not exist
    And the wp-includes/Requests/Exception/Transport/cURL.php file should not exist
    And the wp-includes/Requests/Exception/HTTP/502.php file should not exist
    And the wp-includes/Requests/IRI.php file should not exist
    And the wp-includes/Requests/src/Transport/Curl.php file should exist
    And the wp-includes/Requests/src/Exception/Transport/Curl.php file should exist
    And the wp-includes/Requests/src/Exception/Http/Status502.php file should exist
    And the wp-includes/Requests/src/Iri.php file should exist
    And STDOUT should contain:
      """
      Cleaning up files...
      """

    When I run `wp option add str_opt 'bar'`
    Then STDOUT should not be empty
    When I run `wp post create --post_title='Test post' --porcelain`
    Then STDOUT should be a number

  @require-php-7.4
  Scenario Outline: Use `--version=(nightly|trunk)` to update to the latest nightly version
    Given a WP install

    When I run `wp core update --version=<version>`
    Then STDOUT should contain:
      """
      Updating to version nightly (en_US)...
      Downloading update from https://wordpress.org/nightly-builds/wordpress-latest.zip...
      """
    And STDOUT should contain:
      """
      Success: WordPress updated successfully.
      """

    Examples:
      | version    |
      | trunk      |
      | nightly    |

  @require-php-7.4
  Scenario: Installing latest nightly build should skip cache
    Given a WP install

    # May produce warnings if checksums cannot be retrieved.
    When I try `wp core upgrade --force http://wordpress.org/nightly-builds/wordpress-latest.zip`
    Then STDOUT should contain:
      """
      Success:
      """
    And STDOUT should not contain:
      """
      Using cached
      """

    # May produce warnings if checksums cannot be retrieved.
    When I try `wp core upgrade --force http://wordpress.org/nightly-builds/wordpress-latest.zip`
    Then STDOUT should contain:
      """
      Success:
      """
    And STDOUT should not contain:
      """
      Using cached
      """

  Scenario: Allow installing major version with trailing zero
    Given a WP install

    When I run `wp core update --version=6.2.0 --force`
    Then STDOUT should contain:
      """
      Success:
      """

  Scenario: No HTML output from async translation updates during core update
    Given a WP install
    And an empty cache

    # Using `try` in case there are checksum warnings.
    When I try `wp core download --version=6.5 --locale=de_DE --force`
    Then STDOUT should contain:
      """
      Success: WordPress downloaded.
      """

    When I run `wp core version --extra`
    Then STDOUT should contain:
      """
      Package language:  de_DE
      """

    When I run `wp core update --version=latest --force`
    Then STDOUT should not contain:
      """
      <p>
      """
    And STDOUT should not contain:
      """
      <div
      """
    And STDOUT should not contain:
      """
      <script
      """
    And STDOUT should not contain:
      """
      </div>
      """
