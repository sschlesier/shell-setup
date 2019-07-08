FROM fedora
CMD /usr/bin/zsh
ENV TERM=xterm-256color

RUN useradd --create-home --shell /usr/bin/zsh user
WORKDIR /home/user

# cache an updated set of repos
RUN dnf makecache

COPY shell-bootstrap .
RUN ./shell-bootstrap

USER user
COPY shell-chezmoi .
RUN ./shell-chezmoi

COPY shell-antibody .
RUN ./shell-antibody

COPY shell-vimplug .
RUN ./shell-vimplug

COPY shell-tmux .
RUN ./shell-tmux

COPY shell-manual-install .
RUN ./shell-manual-install

RUN rm -f shell*
