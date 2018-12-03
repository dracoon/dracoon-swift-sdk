# remove local carthage git from Cartfile
cat Cartfile | grep -v "file" > NewCartfile
mv NewCartfile Cartfile

# Add Dependency to the parent folder
echo "git \"file://$(pwd)/../../sdk-swift\"" >> Cartfile

carthage bootstrap --no-use-binaries --platform ios
