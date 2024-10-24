FROM python:3.10

WORKDIR "/app"

# install the latest TabPy
RUN python3 -m pip install --upgrade pip \
    && \
    python3 -m pip install --upgrade tabpy

# copy files needed by container
COPY ./start.sh /
COPY ./its-configs/ /its-configs/

# run startup script
RUN chmod +x /start.sh
CMD ["/start.sh"]
