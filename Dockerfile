FROM fedora

RUN dnf -y install neovim python3 ddgr zsh git wget python tmux
RUN sed -i 's/\/bin\/bash$/\/usr\/bin\/zsh/' /etc/passwd

RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
RUN nvim +PluginInstall +qall

#hack to improve build times
COPY .local/share/chezmoi/dot_zsh_plugins.txt /root/.zsh_plugins.txt
COPY antibody /usr/local/bin
RUN antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

COPY . /root/
RUN mv /root/antibody /usr/local/bin && mv /root/chezmoi /usr/local/bin/

RUN chmod 0700 ~/.local/share/chezmoi
RUN chezmoi apply

CMD /usr/bin/zsh
