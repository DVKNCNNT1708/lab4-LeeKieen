# Sử dụng base image nhẹ
FROM python:3.11-slim

# Cài đặt curl cho lệnh HEALTHCHECK
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Tạo user không phải root
RUN useradd -m appuser
WORKDIR /app

# Cài đặt dependency trước để tận dụng cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ thư mục src
COPY src/ ./src/

# Thiết lập quyền cho user
RUN chown -R appuser:appuser /app
USER appuser

# Cấu hình kiểm tra sức khỏe dịch vụ
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000
CMD ["uvicorn", "iot_app.main:app", "--app-dir", "src", "--host", "0.0.0.0", "--port", "8000"]