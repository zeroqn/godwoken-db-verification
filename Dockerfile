FROM nervos/godwoken-prebuilds:v0.6.8-rc1

USER root

COPY ./entrypoint.sh /bin/

RUN chmod +x /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
