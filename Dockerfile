FROM archlinux/base
ENV TERM=xterm-256color
CMD /usr/bin/zsh

COPY shell-bootstrap /root/
RUN sh /root/shell-bootstrap

COPY shell-chezmoi /root/
RUN sh /root/shell-chezmoi

COPY shell-antibody /root/
RUN sh /root/shell-antibody

COPY shell-vimplug /root/
RUN sh /root/shell-vimplug

COPY shell-tmux /root/
RUN sh /root/shell-tmux
