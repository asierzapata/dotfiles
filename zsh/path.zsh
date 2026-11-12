export PATH="$ZSH/bin:$HOME/.local/bin:$PATH"

# Go command runners reject relative PATH entries (for example, ./bin).
path=(${path:#./bin})
path=(${path:#.})
