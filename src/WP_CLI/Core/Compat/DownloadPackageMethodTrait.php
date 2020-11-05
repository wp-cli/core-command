<?php

namespace WP_CLI\Core\Compat;

// phpcs:disable Generic.Files.OneObjectStructurePerFile.MultipleFound,Generic.Classes.DuplicateClassName.Found

if ( \WP_CLI\Utils\wp_version_compare( '5.5-alpha-48399', '>=' ) ) {

	require_once __DIR__ . '/Min_WP_5_5/DownloadPackageMethodTrait.php';

	trait DownloadPackageMethodTrait {

		use Min_WP_5_5\DownloadPackageMethodTrait;
	}

	return;
}

require_once __DIR__ . '/Min_WP_3_7/DownloadPackageMethodTrait.php';

trait DownloadPackageMethodTrait {

	use Min_WP_3_7\DownloadPackageMethodTrait;
}
