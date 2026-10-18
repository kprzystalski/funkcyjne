FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir notebook ipykernel

EXPOSE 8888

CMD ["jupyter", "notebook", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--allow-root"]

