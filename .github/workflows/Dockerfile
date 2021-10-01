# Create a docker image with postgres version 11.5 that adds the sv_SE locale
FROM postgres:11.5
RUN localedef -i sv_SE -c -f UTF-8 -A /usr/share/locale/locale.alias sv_SE.UTF-8
