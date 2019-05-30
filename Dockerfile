FROM fedora

RUN dnf -y install neovim python3 ddgr zsh git wget python tmux unzip
RUN sed -i 's/\/bin\/bash$/\/usr\/bin\/zsh/' /etc/passwd

RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

#hack to improve build times pre-build shell plugins
COPY home/.local/share/chezmoi/dot_zsh_plugins.txt /root/.zsh_plugins.txt
COPY ulb/ /usr/local/bin
RUN antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

#hack to improve build times pre-build vim plugins
COPY home/.local/share/chezmoi/dot_vimrc /root/.vimrc
COPY home/.local/share/chezmoi/private_dot_config/nvim/init.vim /root/.config/nvim/init.vim
RUN nvim +PluginInstall +qall

COPY home/ /root
# RUN mv /root/antibody /usr/local/bin && mv /root/chezmoi /usr/local/bin/

RUN chmod 0700 ~/.local/share/chezmoi
RUN chezmoi apply

CMD /usr/bin/zsh
