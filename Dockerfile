FROM python:3.10

WORKDIR /app

# install the latest TabPy
RUN python3 -m pip install --upgrade pip \
    && \
    python3 -m pip install --upgrade tabpy

# copy files needed by container
COPY ./password-file.txt ./start.sh /

# set environment variables
ENV TABPY_PWD_FILE="/app/password-file.txt"

# start TabPy
CMD ["sh", "-c", "tabpy"]

# run startup script
RUN chmod +x /start.sh
CMD ["/start.sh"]
