setup() {
   source getopt_long.sh
}

@test "can set long option with no argument" {
   add_long_option "list-components" $GETOPT_LONG_ARG_NONE
}

@test "can set long option with required argument" {
   add_long_option "list-components" $GETOPT_LONG_ARG_REQUIRED
}

@test "can set long option with optional argument" {
   add_long_option "list-components" $GETOPT_LONG_ARG_OPTIONAL
}

@test "can set short option with no argument" {
   add_short_option "list-components" $GETOPT_LONG_ARG_NONE
}

@test "can set short option with required argument" {
   add_short_option "list-components" $GETOPT_LONG_ARG_REQUIRED
}

@test "can set short option with optional argument" {
   add_short_option "list-components" $GETOPT_LONG_ARG_OPTIONAL
}
