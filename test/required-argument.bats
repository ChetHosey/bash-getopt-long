load '../node_modules/bats-assert/load.bash'
load '../node_modules/bats-support/load.bash'

setup() {
   source getopt_long.sh
}

@test "required argument returns option as question mark without parameter" {
   _gol_reset --required-argument

   add_long_option "required-argument" $GETOPT_LONG_ARG_REQUIRED

   getopt_long option value

   assert_equal "$option" '?'
}

@test "required argument returns argument name as parameter when missing parameter" {
   _gol_reset --required-argument

   add_long_option "required-argument" $GETOPT_LONG_ARG_REQUIRED

   getopt_long option value

   assert_equal "$value" 'required-argument'
}

@test "required argument prints warning when missing parameter" {
   _gol_reset --required-argument

   add_long_option "required-argument" $GETOPT_LONG_ARG_REQUIRED

   run getopt_long option value

   assert_output 'Warning: no argument supplied for --required-argument'
}

@test "required argument returns correct option name and value" {
   _gol_reset --required-argument=present

   add_long_option "required-argument" $GETOPT_LONG_ARG_REQUIRED

   getopt_long option value

   assert_equal "$option" 'required-argument'
   assert_equal "$value" 'present'
}
