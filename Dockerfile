FROM alpine
ENV TERM=xterm-256color
CMD /usr/bin/zsh

COPY shell-bootstrap /root/
RUN chmod +x /root/shell-bootstrap && /root/shell-bootstrap

COPY shell-chezmoi /root/
RUN chmod +x /root/shell-chezmoi && /root/shell-chezmoi

COPY shell-antibody /root/
RUN chmod +x /root/shell-antibody && /root/shell-antibody

COPY shell-vimplug /root/
RUN chmod +x /root/shell-vimplug && /root/shell-vimplug

COPY shell-tmux /root/
RUN chmod +x /root/shell-tmux && /root/shell-tmux
