@test "the entry for 2.3.4.5 has the options" {
  cat /etc/hosts | grep "2.3.4.5[[:space:]]www.example.com[[:space:]]foo[[:space:]]bar[[:space:]]# This is a comment @100"
}
