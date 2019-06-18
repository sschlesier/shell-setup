FROM fedora

RUN dnf -y install neovim python3 ddgr zsh git wget python tmux unzip fzf fd-find the_silver_searcher ruby exa
ENV TERM=xterm-256color
RUN sed -i 's/\/bin\/bash$/\/usr\/bin\/zsh/' /etc/passwd

#hack to improve build times pre-build shell plugins
COPY home/.local/share/chezmoi/dot_zsh/zsh_plugins.txt /root/.zsh/zsh_plugins.txt
COPY ulb/ /usr/local/bin
RUN antibody bundle < ~/.zsh/zsh_plugins.txt #ensure files are cached

#hack to improve build times pre-build vim plugins
COPY home/.local/share/chezmoi/dot_vimrc /root/.vimrc
COPY home/.local/share/chezmoi/private_dot_config/nvim/init.vim /root/.config/nvim/init.vim
COPY home/.local/share/chezmoi/dot_vim/autoload/plug.vim /root/.vim/autoload/plug.vim
RUN nvim +PlugInstall +qall

COPY home/ /root
RUN echo "export EMAIL=scott+tst@schlesier.ca" > ~/.zsh/shell_environment.zsh #hack in shell_environment

RUN chmod 0700 /root/.local/share/chezmoi
RUN chezmoi apply

CMD /usr/bin/zsh
