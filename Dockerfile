# JupyterLab with Kotlin and Scala 3 for functional programming exercises.
# Builds on linux/amd64 and linux/arm64 (including Apple Silicon hosts).
FROM eclipse-temurin:21-jdk-jammy

ARG KOTLIN_VERSION=2.4.21
ARG SCALA_CLI_VERSION=1.18.0

ENV DEBIAN_FRONTEND=noninteractive \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:/opt/kotlin/kotlinc/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# The notebooks use a Python kernel that delegates to Kotlin/Scala CLIs.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl unzip gzip python3 python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir jupyterlab ipykernel

# Kotlin/JVM compiler + kotlin runner (kotlinc, kotlin).
RUN set -eux; \
    curl -fSL --retry 3 \
      "https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip" \
      -o /tmp/kotlin.zip; \
    mkdir -p /opt/kotlin; \
    unzip -q /tmp/kotlin.zip -d /opt/kotlin; \
    chmod +x /opt/kotlin/kotlinc/bin/*; \
    rm /tmp/kotlin.zip

# Scala 3 via the official Scala CLI. Architecture-aware for ARM64/x86_64.
RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
      amd64) scala_arch=x86_64 ;; \
      arm64) scala_arch=aarch64 ;; \
      *) echo "Unsupported architecture" >&2; exit 1 ;; \
    esac; \
    curl -fSL --retry 3 \
      "https://github.com/Virtuslab/scala-cli/releases/download/v${SCALA_CLI_VERSION}/scala-cli-${scala_arch}-pc-linux.gz" \
      -o /tmp/scala-cli.gz; \
    gzip -d -c /tmp/scala-cli.gz > /usr/local/bin/scala-cli; \
    chmod +x /usr/local/bin/scala-cli; \
    rm /tmp/scala-cli.gz; \
    printf '#!/bin/sh\nexec scala-cli "$@"\n' > /usr/local/bin/scala; \
    chmod +x /usr/local/bin/scala

# Verify that the executables needed by the notebooks are available.
RUN java -version \
    && kotlinc -version \
    && scala-cli version \
    && python -m jupyter --version

WORKDIR /workspace
EXPOSE 8888

# Keep Jupyter authentication enabled: find the login token in docker logs.
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--ServerApp.root_dir=/workspace"]
