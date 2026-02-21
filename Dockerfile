# VoiceBox API - GPU-enabled Docker image
# Uses NVIDIA PyTorch base for optimal CUDA support

FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

LABEL maintainer="EcomGraduates"
LABEL description="VoiceBox TTS API with GPU support"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Set HuggingFace cache directory (can be mounted as volume)
ENV HF_HOME=/app/models
ENV TRANSFORMERS_CACHE=/app/models
ENV TORCH_HOME=/app/models

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    libsndfile1-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY backend/requirements.txt /app/requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Install Qwen3-TTS from git (as per setup docs)
RUN pip install --no-cache-dir git+https://github.com/QwenLM/Qwen3-TTS.git

# Copy backend code
COPY backend/ /app/

# Create directories for data persistence
RUN mkdir -p /app/data /app/models /app/audio

# Expose the API port
EXPOSE 17493

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:17493/health || exit 1

# Run the server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "17493"]