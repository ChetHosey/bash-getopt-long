@test "should succeed" {
   run echo "Hello, bats!"
   assert_success
}

load 'libs/bats-assert/load'

setup() {
   source getopt_long.sh
}

@test "should fail" {
   run /bin/false
   assert_failure
}
