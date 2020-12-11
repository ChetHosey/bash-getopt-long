@test "should succeed" {
   run echo "Hello, bats!"
   assert_success
}

load '../node_modules/bats-assert/load.bash'

setup() {
   source getopt_long.sh
}

@test "should fail" {
   run /bin/false
   assert_failure
}
