
.PHONY : log build targets pods audit debug test xcode_tests clean project audit

# BUCK=buck # System version
BUCK=./buck.pex # Custom version

log:
	echo "Make"

update_cocoapods:
	pod repo update
	pod install

build:
	$(BUCK) build //App:RealmDebugBundle

debug:
	$(BUCK) install //App:RealmDebugBundle --run

install_framework:
	if [ ! -d "./vendors/Realm-static.framework" ]; then \
		echo "downloading Realm framework"; \
		wget "https://static.realm.io/downloads/objc/realm-objc-3.13.1.zip" -O realm.zip; \
		unzip realm.zip; \
		rm realm.zip; \
		mv realm-objc-3.13.1/ios/static/Realm.framework vendors/Realm-static.framework; \
		mv realm-objc-3.13.1/ios/dynamic/Realm.framework vendors/Realm-dynamic.framework; \
		rm -rf realm-objc-3.13.1; \
	fi

targets:
	$(BUCK) targets //...

ci: targets build test project xcode_tests
	echo "Done"

clean:
	killall Xcode || true
	killall Simulator || true
	rm -rf **/*.xcworkspace
	rm -rf **/*.xcodeproj
	$(BUCK) clean

project: install_framework clean
	$(BUCK) --version
	$(BUCK) project //App:workspace
	open App/RealmDebug.xcworkspace
