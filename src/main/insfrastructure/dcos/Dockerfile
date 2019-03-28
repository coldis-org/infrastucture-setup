FROM hashicorp/terraform:0.11.13

# Installs AWS CLI.
RUN apk -v --update add \
		python \
		py-pip \
		groff \
		less \
		mailcap \
		&& \
	pip install --upgrade awscli==1.14.5 s3cmd==2.0.1 python-magic && \
	apk -v --purge del py-pip && \
	rm /var/cache/apk/*

# Creates the work dir.
RUN mkdir /project
WORKDIR /project
VOLUME /project

# Copies the docker entrypoint.
COPY script/run.sh /usr/bin/init

ENTRYPOINT [ "init" ]