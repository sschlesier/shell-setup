FROM fedora

RUN dnf -y install neovim python3 ddgr zsh git wget python tmux unzip fzf fd-find the_silver_searcher ruby
ENV TERM=xterm-256color
RUN sed -i 's/\/bin\/bash$/\/usr\/bin\/zsh/' /etc/passwd

RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

#hack to improve build times pre-build shell plugins
COPY home/.local/share/chezmoi/dot_zsh/zsh_plugins.txt /root/.zsh/zsh_plugins.txt
COPY ulb/ /usr/local/bin
RUN antibody bundle < ~/.zsh/zsh_plugins.txt #ensure files are cached

#hack to improve build times pre-build vim plugins
COPY home/.local/share/chezmoi/dot_vimrc /root/.vimrc
COPY home/.local/share/chezmoi/private_dot_config/nvim/init.vim /root/.config/nvim/init.vim
RUN nvim +PluginInstall +qall

COPY home/ /root

RUN chmod 0700 /root/.local/share/chezmoi
RUN chezmoi apply

CMD /usr/bin/zsh
