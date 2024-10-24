FROM python:3.10

WORKDIR "/app"

# install the latest TabPy
RUN python3 -m pip install --upgrade pip \
    && \
    python3 -m pip install --upgrade tabpy

# copy files needed by container
COPY ./start.sh /
COPY ./its-configs/ /its-configs/

# set environment variables
#
# NB: it appears that the TABPY_PWD_FILE var must be set both
# in the environment, and in the custom.conf file. Omitting it
# from either causes errors.
ENV TABPY_PWD_FILE="/its-configs/password-file.txt"

# start TabPy
CMD ["sh", "-c", "tabpy", "--config=/its-configs/custom.conf"]

# run startup script
RUN chmod +x /start.sh
CMD ["/start.sh"]
