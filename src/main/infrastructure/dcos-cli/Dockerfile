# From debian.
FROM debian:8.11-slim

# Installs DCOS CLI.
RUN [ -d /usr/local/bin ] || sudo mkdir -p /usr/local/bin && \
	apt-get update -y && \
	apt-get install -y curl && \
	curl https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.12/dcos -o dcos && \
	apt-get remove -y curl && \
	apt-get autoremove -y && \
	apt-get clean -y && \
	rm -rf /var/lib/apt/lists/* && \
	mv dcos /usr/local/bin && \
	chmod +x /usr/local/bin/dcos
	
# Installs ssh.
RUN apt-get update -y && \
	apt-get install -y ssh && \
	apt-get clean -y && \
	rm -rf /var/lib/apt/lists/*
	
# Installs jq.
RUN apt-get update -y && \
	apt-get install -y jq && \
	apt-get clean -y && \
	rm -rf /var/lib/apt/lists/*

# Creates the work dir.
RUN mkdir /project
WORKDIR /project
VOLUME /project

# Copies the dcos scripts.
RUN mkdir -p /opt/dcos-script
COPY script /opt/dcos-script
RUN ln -s /opt/dcos-script/*.sh /usr/bin && \
	for f in /usr/bin/dcos*.sh; \
	do \
		mv -- "$f" "${f%.sh}"; \
	done

# Entrypoint.
ENTRYPOINT [ "dcos_init" ]
