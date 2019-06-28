FROM fedora
ENV TERM=xterm-256color
CMD /usr/bin/zsh

COPY shell-bootstrap /root/
RUN chmod +x /root/shell-bootstrap && /root/shell-bootstrap
