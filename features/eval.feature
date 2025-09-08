Feature: Evaluating PHP code and files.

  Scenario: Basics
    Given a FP install

    When I run `fp eval 'var_dump(defined("FP_CONTENT_DIR"));'`
    Then STDOUT should contain:
      """
      bool(true)
      """

    Given a script.php file:
      """
      <?php
      FP_CLI::line( implode( ' ', $args ) );
      """

    When I run `fp eval-file script.php foo bar`
    Then STDOUT should contain:
      """
      foo bar
      """

    Given a script.sh file:
      """
      #! /bin/bash
      <?php
      FP_CLI::line( implode( ' ', $args ) );
      """

    When I run `fp eval-file script.sh foo bar`
    Then STDOUT should contain:
      """
      foo bar
      """
    But STDOUT should not contain:
      """
      #!
      """

  Scenario: Eval without FinPress install
    Given an empty directory

    When I try `fp eval 'var_dump(defined("FP_CONTENT_DIR"));'`
    Then STDERR should contain:
      """
      Error: This does not seem to be a FinPress install
      """
    And the return code should be 1

    When I run `fp eval 'var_dump(defined("FP_CONTENT_DIR"));' --skip-finpress`
    Then STDOUT should contain:
      """
      bool(false)
      """

  Scenario: Eval file without FinPress install
    Given an empty directory
    And a script.php file:
      """
      <?php
      var_dump(defined("FP_CONTENT_DIR"));
      """

    When I try `fp eval-file script.php`
    Then STDERR should contain:
      """
      Error: This does not seem to be a FinPress install
      """
    And the return code should be 1

    When I run `fp eval-file script.php --skip-finpress`
    Then STDOUT should contain:
      """
      bool(false)
      """

  Scenario: Eval stdin with args
    Given an empty directory
    And a script.php file:
      """
      <?php
      FP_CLI::line( implode( ' ', $args ) );
      """

    When I run `cat script.php | fp eval-file - x y z --skip-finpress`
    Then STDOUT should contain:
      """
      x y z
      """

  @require-php-7.0
  Scenario: Eval stdin with use-include parameter without FinPress install
    Given an empty directory
    And a script.php file:
      """
      <?php
      declare(strict_types=1);
      FP_CLI::line( implode( ' ', $args ) );
      """

    When I try `cat script.php | fp eval-file - foo bar --skip-finpress --use-include`
    Then STDERR should be:
      """
      Error: "-" and "--use-include" parameters cannot be used at the same time
      """
    And the return code should be 1

  @require-php-7.0
  Scenario: Eval file with use-include parameter without FinPress install
    Given an empty directory
    And a script.php file:
      """
      <?php
      declare(strict_types=1);
      FP_CLI::line( implode( ' ', $args ) );
      """

    When I run `fp eval-file script.php foo bar --skip-finpress --use-include`
    Then STDOUT should contain:
      """
      foo bar
      """

  @require-php-7.0
  Scenario: Eval stdin with use-include parameter
    Given a FP install
    And a script.php file:
      """
      <?php
      declare(strict_types=1);
      FP_CLI::line( implode( ' ', $args ) );
      """
    When I try `cat script.php | fp eval-file - foo bar --use-include`
    Then STDERR should be:
      """
      Error: "-" and "--use-include" parameters cannot be used at the same time
      """
    And the return code should be 1

  @require-php-7.0
  Scenario: Eval file with use-include parameter
    Given a FP install
    And a script.php file:
      """
      <?php
      declare(strict_types=1);
      FP_CLI::line( implode( ' ', $args ) );
      """

    When I run `fp eval-file script.php foo bar --use-include`
    Then STDOUT should contain:
      """
      foo bar
      """

  Scenario: Eval-file will use the correct __FILE__ constant value
    Given an empty directory
    And a script.php file:
      """
      <?php
      echo __FILE__;
      """

    When I run `fp eval-file script.php --skip-finpress`
    Then STDOUT should contain:
      """
      /script.php
      """
    And STDOUT should not contain:
      """
      eval()'d code
      """

  Scenario: Eval-file will not replace __FILE__ when quoted
    Given an empty directory
    And a script.php file:
      """
      <?php
      echo '__FILE__';
      echo "__FILE__";
      echo '"__FILE__"';
      echo "'__FILE__'";

      echo ' foo __FILE__ bar ';
      echo " foo __FILE__ bar ";
      echo '" foo __FILE__ bar "';
      echo "' foo __FILE__ bar '";
      """

    When I run `fp eval-file script.php --skip-finpress`
    Then STDOUT should contain:
      """
      __FILE__
      """
    And STDOUT should not contain:
      """
      /script.php
      """
    And STDOUT should not contain:
      """
      eval()'d code
      """

  Scenario: Eval-file can handle both quoted and unquoted __FILE__ correctly
    Given an empty directory
    And a script.php file:
      """
      <?php
      echo ' __FILE__ => ' . __FILE__;
      """

    When I run `fp eval-file script.php --skip-finpress`
    Then STDOUT should contain:
      """
      __FILE__ =>
      """
    And STDOUT should contain:
      """
      /script.php
      """
    And STDOUT should not contain:
      """
      eval()'d code
      """

  Scenario: Eval-file will use the correct __FILE__ constant value
    Given an empty directory
    And a script.php file:
      """
      <?php
      echo __FILE__ . PHP_EOL;
      """
    And a dir_script.php file:
      """
      <?php
      echo __DIR__ . '/script.php' . PHP_EOL;
      """
    And I run `fp eval-file script.php --skip-finpress`
    And save STDOUT as {FILE_OUTPUT}

    When I run `fp eval-file dir_script.php --skip-finpress`
    Then STDOUT should be:
      """
      {FILE_OUTPUT}
      """
    And STDOUT should not contain:
      """
      eval()'d code
      """
