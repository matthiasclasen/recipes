include Makefile.config

all: test

test: test-repo
	flatpak-builder --force-clean --repo=test-repo --ccache --require-changes --from-git=git://git.gnome.org/recipes --from-git-branch=master recipes flatpak/org.gnome.Recipes.json
	flatpak-builder --force-clean --arch=i386 --repo=test-repo --ccache --require-changes --from-git=git://git.gnome.org/recipes --from-git-branch=master recipes flatpak/org.gnome.Recipes.json
	flatpak build-update-repo test-repo

release: repo
	if [ "x${RELEASE_GPG_KEY}" == "x" ]; then echo Must set RELEASE_GPG_KEY in Makefile.config, try \'make gpg-key\'; exit 1; fi
	flatpak-builder --verbose --force-clean --repo=repo  --ccache --gpg-homedir=gpg --gpg-sign=${RELEASE_GPG_KEY} --from-git=git://git.gnome.org/recipes --from-git-branch=master recipes  flatpak/org.gnome.Recipes.json
	flatpak-builder --verbose --force-clean --arch=i386 --repo=repo  --ccache --gpg-homedir=gpg --gpg-sign=${RELEASE_GPG_KEY} --from-git=git://git.gnome.org/recipes --from-git-branch=master recipes  flatpak/org.gnome.Recipes.json
	flatpak build-update-repo --generate-static-deltas --gpg-homedir=gpg --gpg-sign=${RELEASE_GPG_KEY} repo

test-repo:
	ostree init --mode=archive-z2 --repo=test-repo

repo:
	ostree init --mode=archive-z2 --repo=repo

gpg-key:
	if [ "x${KEY_USER}" == "x" ]; then echo Must set KEY_USER in Makefile.config; exit 1; fi
	mkdir -p gpg
	gpg2 --homedir gpg --quick-gen-key ${KEY_USER}
	echo Enter the above gpg key id as RELEASE_GPG_KEY in Makefile.config

gnome-recipes.flatpakref: gnome-recipes.flatpakref.in
	sed -e 's|@URL@|${URL}|g' -e 's|@GPG@|$(shell gpg2 --homedir=gpg --export ${RELEASE_GPG_KEY} | base64 | tr -d '\n')|' $< > $@
