# remove local carthage git from Cartfile
cat Cartfile | grep -v "file" > NewCartfile
mv NewCartfile Cartfile

# Add Dependency to the parent folder
echo "git \"file://$(pwd)/../../\"" >> Cartfile

chmod +x carthage-build.sh
carthage bootstrap --no-use-binaries --platform ios --use-xcframeworks
