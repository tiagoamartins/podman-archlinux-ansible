FROM archlinux:base
LABEL maintainer="Tiago Martins"
ENV container=podman

RUN pacman --noconfirm -Syu systemd; \
	yes | pacman -Scc; \
	rm -rf /usr/share/doc; \
	rm -rf /usr/share/man; \
	rm -f /lib/systemd/system/multi-user.target.wants/*; \
	rm -f /etc/systemd/system/*.wants/*; \
	rm -f /lib/systemd/system/local-fs.target.wants/*; \
	rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
	rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
	rm -f /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup*; \
	rm -f /lib/systemd/system/systemd-update-utmp*; \
	rm -f /lib/systemd/system/basic.target.wants/*

RUN pacman --noconfirm -Sy \
	python-pip \
	sudo \
	&& yes | pacman -Scc

# Install ansible
RUN python -m pip install --upgrade pip \
	&& python -m pip install ansible

# Disable requiretty
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers

# Install ansible configuration files
RUN mkdir /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
RUN echo -e '[defaults]\nstdout_callback = debug\ninterperter_python = auto_silent\n' > /etc/ansible/ansible.cfg

STOPSIGNAL SIGRTMIN+3
ENTRYPOINT ["/usr/lib/systemd/systemd"]
