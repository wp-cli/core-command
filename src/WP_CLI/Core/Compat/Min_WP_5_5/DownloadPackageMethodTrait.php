<?php

namespace WP_CLI\Core\Compat\Min_WP_5_5;

trait DownloadPackageMethodTrait {

	/**
	 * Compatibility method for signature changes to {@see \WP_Upgrader::download_package()}
	 *
	 * @param string $package          The URI of the package. If this is the full path to an
	 *                                 existing local file, it will be returned untouched.
	 * @param bool   $check_signatures Whether to validate file signatures. Default true.
	 * @param array  $hook_extra       Extra arguments to pass to the filter hooks. Default empty array.
	 * @return string|\WP_Error The full path to the downloaded package file, or a WP_Error object.
	 */
	public function download( $package, $check_signatures = true, $hook_extra = [] ) {
		return $this->process_download_package( $package, $check_signatures, $hook_extra );
	}
}
