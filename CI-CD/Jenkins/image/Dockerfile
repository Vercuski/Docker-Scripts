# Jenkins LTS with the plugins this stack configures (Configuration as Code, Pipeline, Git, Gitea, Docker Pipeline)
# and the Docker CLI, so pipelines can run steps in containers: agent { docker { image '...' } }
ARG JENKINS_VERSION=2.580.2-lts-jdk21
ARG DOCKER_CLI_VERSION=29-cli
FROM docker:${DOCKER_CLI_VERSION} AS docker-cli

FROM jenkins/jenkins:${JENKINS_VERSION}
COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
