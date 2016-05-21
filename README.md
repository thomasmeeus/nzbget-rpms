# nzbget-packages

Unofficial packages for [Nzbget](http://nzbget.net/).

Packages are currently only provided for EL7.

## Installation

### Installing from COPR

Precompiled packages can be found in the [cosmopetrich/nzbget COPR repository](
/root/nzbget-packages/Dockerfile). You should only use these if you've inspected
the SRPM on COPR, or if you really trust me.

The COPR repo can be enabled by installing the [appropriate plugin](
https://fedorahosted.org/copr/wiki/HowToEnableRepo), or by creating a .repo file
under /etc/yum/yum.repos.d. Sample .repo files can be obtained by hitting the
'repo download' button for the appropriate release on the project's COPR landing
page.

### Building manually

I've hacked together a horrible makefile to build and release this package since
I couldn't find a public build server or CI system that can build an SPEC file
with an external source from scratch.

If you don't want to use the Makefile then you should be able to build the
package directly with mock or rpmbuild easily enough, just make sure you pass in
the `_pkg_version` and `_pkg_release` defines with the appropriate values.

To use the makefile, follow the procedure below.

 1. Clone this repository somewhere.
 2. Install some required packages.

    ```
    yum install rpmdevtools yum-utils
    ```

 3. Install build dependencies.

    ```
    sudo yum-builddep SPECS/nzbget.spec
    ```

 4. Build the RPM.

    ```
    make rpm
    ```

    Or just the SRPM.

    ```
    make srpm
    ```

The resulting files will be saved into RPMS/ or SRPMs/ inside the repo.

## Usage

Once the package is installed, edit /etc/nzbget.conf and make sure that the
initial settings are to your liking. The config included in the package uses
the default username and password, but listens on localhost only by default.

Once you're happy with config, enable and start the nzbget service.

```
systemctl start nzbget
systemtl enable nzbget
```

## Release process

I was aiming for semi-reproducible builds. Unfortunately none of the public
build servers I know of can build a SPEC file with external sources. Using a
full CI system is another option, but most of those (Travis, Circle) use Ubuntu
for their build environments.

As an interim measure, I'm building the SRPM locally, uploading it to Github
Releases, then telling COPR to build directly from there.

The rough procedure I use is documented below.

 1. Install and configure [aktau/github-release](https://github.com/aktau/github-release).
 2. Install and configure the [COPR cli](https://developer.fedoraproject.org/deployment/copr/copr-cli.html).
 3. Bump the version or release at the top of the Makefile.
 4. Build a package locally.

    ```
    make rpm
    ```

 5. Test the new package.
 6. Do a `git commit`, then tag the new commit.

    ```
    make release-tag
    ```
 7. Upload the SRPM to github.

    ```
    make release-create
    make release-upload  
    ```

 8. Tell COPR to build the new SRPM.

    ```
    make release-build
    ```
