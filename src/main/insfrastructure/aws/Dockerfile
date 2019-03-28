FROM mesosphere/aws-cli:1.14.5

RUN mkdir -p /opt/aws-script
COPY script /opt/aws-script
RUN ln -s /opt/aws-script/*.sh /usr/bin && \
	for f in /usr/bin/aws*.sh; \
	do \
		mv -- "$f" "${f%.sh}"; \
	done

ENTRYPOINT [ "/bin/sh", "-c" ]