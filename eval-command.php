<?php

if ( ! class_exists( 'FIN_CLI' ) ) {
	return;
}

$fincli_eval_autoloader = __DIR__ . '/vendor/autoload.php';
if ( file_exists( $fincli_eval_autoloader ) ) {
	require_once $fincli_eval_autoloader;
}

FIN_CLI::add_command( 'eval', 'Eval_Command' );
FIN_CLI::add_command( 'eval-file', 'EvalFile_Command' );
