@test "the entry for 2.3.4.5 is created" {
  cat /etc/hosts | grep "2.3.4.5[[:space:]]www.example.com"
}
