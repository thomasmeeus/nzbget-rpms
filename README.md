# nzbget-packages

Unofficial packages for [Nzbget](http://nzbget.net/).

Packages are currently only provided for EL7.

## Installing from COPR

Precompiled packages can be found in the [cosmopetrich/nzbget COPR repository](
/root/nzbget-packages/Dockerfile). You should only use these if you've inspected
the SRPM on COPR, or if you really trust me.

The COPR repo can be enabled by installing the [appropriate plugin](
https://fedorahosted.org/copr/wiki/HowToEnableRepo), or by creating a .repo file
under /etc/yum/yum.repos.d. Sample .repo files can be obtained by hitting the
'repo download' button for the appropriate release on the project's COPR landing
page.

## Building manually

You can skip this if you already know how to drive `rpmbuild`. There's nothing
special about this build.

 1. Clone this repository somewhere.
 2. Install some required packages.

    ```
    yum install rpmdevtools yum-utils
    ```

 3. Set up your build environment.

    ```
    rpmdev-setuptree
    ```

 4. Link the spec file and local sources into the rpmbuild root.

    ```
    ln -s $PWD/SPECS/* $HOME/rpmbuild/SPECS
    ln -s $PWD/SOURCES/* $HOME/rpmbuild/SOURCES
    ```

 5. Download the source tarball from upstream.

    ```
    spectool --get-files --all --sourcedir SPECS/nzbget.spec
    ```

 6. Install build dependencies.

    ```
    yum-builddep SPECS/nzbget.spec
    ```

 7. Build the RPM.

    ```
    rpmbuild --clean -ba SPECS/nzbget.spec
    ```

The resulting RPM will be saved to `$HOME/rpmbuild/RPMS/`. You can then install
it and its dependencies with `yum install PATH_TO_RPM`.
