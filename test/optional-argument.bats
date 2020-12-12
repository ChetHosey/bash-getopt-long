load '../node_modules/bats-assert/load.bash'
load '../node_modules/bats-support/load.bash'

setup() {
   source getopt_long.sh
}

@test "optional argument returns empty value without parameter" {
   _gol_reset --optional-argument

   add_long_option "optional-argument" $GETOPT_LONG_ARG_OPTIONAL

   getopt_long option value

   assert_equal "$option" optional-argument
   assert_equal "$value" ''
}

@test "optional argument returns correct value without parameter" {
   _gol_reset --optional-argument=seventeen

   add_long_option "optional-argument" $GETOPT_LONG_ARG_OPTIONAL

   getopt_long option value

   assert_equal "$option" optional-argument
   assert_equal "$value" seventeen
}
