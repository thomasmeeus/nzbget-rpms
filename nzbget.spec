Name:		nzbget
Version:	16.4
Release:	1%{?dist}
Summary:	Usenet binary downloader

License:	GPLv2
URL:		http://nzbget.net
Source0:	https://github.com/%{name}/%{name}/releases/download/v%{version}/%{name}-%{version}-src.tar.gz
Source1:        nzbget.service
Source2:        nzbget-tmpfiles.conf
Patch0:         nzbget-config.patch

%{?systemd_requires}
BuildRequires:  systemd
BuildRequires:  libxml2-devel
BuildRequires:  ncurses-devel
Requires:       p7zip
Requires(pre):  shadow-utils

%description
NZBGet is an Usenet-client written in C++ and designed with performance in mind
to achieve maximum download speed while using minimal system resources.

%prep
%autosetup

%build
%configure
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}

# Copy the config file into /etc
mkdir -p %{buildroot}/%{_sysconfdir}/%{name}
install -m 644 %{buildroot}%{_datadir}/%{name}/%{name}.conf \
               %{buildroot}%{_sysconfdir}/%{name}.conf

# Create an empty data directory
mkdir -p %{buildroot}%{_sharedstatedir}/%{name}

# Install the systemd service unit
mkdir -p %{buildroot}%{_unitdir}
install -m 644 %{SOURCE1} %{buildroot}%{_unitdir}/%{name}.service

# Ensure that the /run directory is created
mkdir -p %{buildroot}%{_tmpfilesdir}
install -m 0644 %{SOURCE2} %{buildroot}%{_tmpfilesdir}/%{name}.conf
mkdir -p %{buildroot}/run/%{name}

%files
%license /usr/share/doc/%{name}/COPYING
%doc /usr/share/doc/%{name}/AUTHORS
%doc /usr/share/doc/%{name}/ChangeLog
%doc /usr/share/doc/%{name}/README
%{_bindir}/%{name}
%{_datadir}/%{name}/*
%{_unitdir}/%{name}.service
%{_tmpfilesdir}/%{name}.conf
%attr(0755,%{name},%{name}) %{_sharedstatedir}/%{name}
%attr(0755,%{name},%{name}) /run/%{name}
%config(noreplace) %{_sysconfdir}/%{name}.conf

%pre
/usr/bin/getent group %{name} >/dev/null || /usr/sbin/groupadd -r %{name}
/usr/bin/getent passwd %{name} /dev/null || \
	/usr/sbin/useradd -r -g %{name} -d %{_datadir}/%{name} -s /sbin/nologin \
	-c "Nzbget usenet binary downloader" %{name}
install -d -o %{name} -g %{name} -m 0755 %{buildroot}%{_sharedstatedir}/%{name}/

%post
%systemd_post %{name}.service

%preun
%systemd_preun %{name}.service

%postun
%systemd_postun_with_restart %{name}.service
test "$1" != 0 || /usr/sbin/userdel  %{name} &>/dev/null || :
test "$1" != 0 || /usr/sbin/groupdel %{name} &>/dev/null || :

%changelog
* Thu May 19 2016 Cosmo Petrich <rpm@krogoth.net> 16.4-1
- Initial release.
