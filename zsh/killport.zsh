killport() {
  port=$1
  kill -9 $(lsof -i:$port -t)
}
