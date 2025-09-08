<?php

if ( ! class_exists( 'FP_CLI' ) ) {
	return;
}

$fpcli_eval_autoloader = __DIR__ . '/vendor/autoload.php';
if ( file_exists( $fpcli_eval_autoloader ) ) {
	require_once $fpcli_eval_autoloader;
}

FP_CLI::add_command( 'eval', 'Eval_Command' );
FP_CLI::add_command( 'eval-file', 'EvalFile_Command' );
