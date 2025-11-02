Feature: Check if WordPress database update is needed

  # This test downgrades to an older WordPress version, but the SQLite plugin requires 6.0+
  @require-mysql
  Scenario: Check if database update is needed on a single site
    Given a WP install
    And a disable_sidebar_check.php file:
      """
      <?php
      WP_CLI::add_wp_hook( 'init', static function () {
        remove_action( 'after_switch_theme', '_wp_sidebars_changed' );
      } );
      """
    And I try `wp theme install twentytwenty --activate`
    And I run `wp core download --version=5.4 --force`
    And I run `wp option update db_version 45805 --require=disable_sidebar_check.php`

    When I try `wp core check-update-db`
    Then the return code should be 1
    And STDOUT should contain:
      """
      WordPress database update required from db version 45805 to 47018.
      """

    When I run `wp core update-db`
    Then STDOUT should contain:
      """
      Success: WordPress database upgraded successfully from db version 45805 to 47018.
      """

    When I run `wp core check-update-db`
    Then STDOUT should contain:
      """
      Success: WordPress database is up to date.
      """

  Scenario: Check if database update is needed when database is already up to date
    Given a WP install

    When I run `wp core check-update-db`
    Then STDOUT should contain:
      """
      Success: WordPress database is up to date.
      """

  Scenario: Check if database update is needed across network
    Given a WP multisite install
    And a disable_sidebar_check.php file:
      """
      <?php
      WP_CLI::add_wp_hook( 'init', static function () {
        remove_action( 'after_switch_theme', '_wp_sidebars_changed' );
      } );
      """
    And I try `wp theme install twentytwenty --activate`
    And I run `wp core download --version=6.6 --force`
    And I run `wp option update db_version 57155 --require=disable_sidebar_check.php`
    And I run `wp site option update wpmu_upgrade_site 57155`
    And I run `wp site create --slug=foo`
    And I run `wp site create --slug=bar`
    And I run `wp site create --slug=burrito --porcelain`
    And save STDOUT as {BURRITO_ID}
    And I run `wp site create --slug=taco --porcelain`
    And save STDOUT as {TACO_ID}
    And I run `wp site create --slug=pizza --porcelain`
    And save STDOUT as {PIZZA_ID}
    And I run `wp site archive {BURRITO_ID}`
    And I run `wp site spam {TACO_ID}`
    And I run `wp site delete {PIZZA_ID} --yes`
    And I run `wp core update`

    When I try `wp core check-update-db --network`
    Then the return code should be 1
    And STDOUT should contain:
      """
      WordPress database update needed on 3/3 sites:
      """

    When I run `wp core update-db --network`
    Then STDOUT should contain:
      """
      Success: WordPress database upgraded on 3/3 sites.
      """

    When I run `wp core check-update-db --network`
    Then STDOUT should contain:
      """
      Success: WordPress databases are up to date on 3/3 sites.
      """

  Scenario: Check database update on network installation errors on single site
    Given a WP install

    When I try `wp core check-update-db --network`
    Then STDERR should contain:
      """
      Error: This is not a multisite installation.
      """
    And the return code should be 1
