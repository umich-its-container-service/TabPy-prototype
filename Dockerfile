FROM python:3.10

WORKDIR "/app"

# install the latest TabPy
RUN pip install --upgrade pip \
    && \
    pip install 'tabpy==2.12'

# copy files needed by container
COPY ./start.sh /
COPY ./its-configs/ /its-configs/

# run startup script
RUN chmod +x /start.sh
CMD ["/start.sh"]
