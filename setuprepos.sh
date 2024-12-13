# Create a repository
if [ ! -d "repos" ]; then
  mkdir repos
  mkdir repos/infrastructure
  mkdir repos/applications
  git init repos/infrastructure
  git init repos/applications
fi  

