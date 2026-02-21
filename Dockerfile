FROM pytorch/pytorch:2.6.0-cuda12.6-cudnn9-runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libsndfile1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV PYTHONUNBUFFERED=1
ENV HF_HOME=/root/.cache/huggingface

COPY backend/requirements.txt backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt \
    && pip install --no-cache-dir git+https://github.com/QwenLM/Qwen3-TTS.git

COPY backend/ backend/

RUN mkdir -p /app/data

EXPOSE 17493

ENTRYPOINT ["python", "-m", "backend.main", "--host", "0.0.0.0", "--port", "17493", "--data-dir", "/app/data"]