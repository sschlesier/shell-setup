FROM fedora
ENV TERM=xterm-256color
CMD /usr/bin/zsh

COPY shell-bootstrap /root/
RUN chmod +x /root/shell-bootstrap && /root/shell-bootstrap

COPY shell-antibody /root/
COPY home/.local/share/chezmoi/dot_zsh/*_compinit_plugins.txt /root/.zsh/
RUN chmod +x /root/shell-antibody && /root/shell-antibody

COPY shell-vimplug /root/
COPY home/.local/share/chezmoi/dot_vimrc /root/.vimrc
COPY home/.local/share/chezmoi/private_dot_config/nvim/init.vim /root/.config/nvim/init.vim
RUN chmod +x /root/shell-vimplug && /root/shell-vimplug

COPY shell-tmux /root/
COPY home/.local/share/chezmoi/dot_tmux.conf /root/.tmux.conf
RUN chmod +x /root/shell-tmux && /root/shell-tmux

COPY shell-chezmoi /root/
COPY home/ /root
RUN chmod +x /root/shell-chezmoi && /root/shell-chezmoi
