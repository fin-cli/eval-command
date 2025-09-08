<?php

use FP_CLI\Utils;

class Eval_Command extends FP_CLI_Command {

	/**
	 * Executes arbitrary PHP code.
	 *
	 * Note: because code is executed within a method, global variables need
	 * to be explicitly globalized.
	 *
	 * ## OPTIONS
	 *
	 * <php-code>
	 * : The code to execute, as a string.
	 *
	 * [--skip-finpress]
	 * : Execute code without loading FinPress.
	 *
	 * ## EXAMPLES
	 *
	 *     # Display FinPress content directory.
	 *     $ fp eval 'echo FP_CONTENT_DIR;'
	 *     /var/www/finpress/fp-content
	 *
	 *     # Generate a random number.
	 *     $ fp eval 'echo rand();' --skip-finpress
	 *     479620423
	 *
	 * @when before_fp_load
	 */
	public function __invoke( $args, $assoc_args ) {

		if ( null === Utils\get_flag_value( $assoc_args, 'skip-finpress' ) ) {
			FP_CLI::get_runner()->load_finpress();
		}

		eval( $args[0] );
	}
}
