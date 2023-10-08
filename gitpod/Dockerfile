FROM gitpod/workspace-full:2023-08-08-12-42-30

USER gitpod

RUN bash -c ". /home/gitpod/.sdkman/bin/sdkman-init.sh && \
    sdk install java 17.0.3-ms && \
    sdk default java 17.0.3-ms && \
    sdk install gradle 8.4"

ENV GRADLE_USER_HOME=/workspace/.gradle/
