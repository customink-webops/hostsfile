@test "the entry for 127.0.0.1 is appended with www.example.com" {
  cat /etc/hosts | grep "127.0.0.1.*www.example.com"
}
