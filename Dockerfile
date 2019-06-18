FROM fedora

RUN dnf -y install neovim python3 ddgr zsh git wget python tmux unzip fzf fd-find the_silver_searcher ruby exa
ENV TERM=xterm-256color
RUN sed -i 's/\/bin\/bash$/\/usr\/bin\/zsh/' /etc/passwd

#hack to improve build times pre-build shell plugins
COPY home/.local/share/chezmoi/dot_zsh/pre_compinit_plugins.txt /root/.zsh/pre_compinit_plugins.txt
COPY home/.local/share/chezmoi/dot_zsh/post_compinit_plugins.txt /root/.zsh/post_compinit_plugins.txt
COPY ulb/ /usr/local/bin
#ensure files are cached
RUN antibody bundle < ~/.zsh/pre_compinit_plugins.txt && \
    antibody bundle < ~/.zsh/post_compinit_plugins.txt

#hack to improve build times pre-build vim plugins
COPY home/.local/share/chezmoi/dot_vimrc /root/.vimrc
COPY home/.local/share/chezmoi/private_dot_config/nvim/init.vim /root/.config/nvim/init.vim
COPY home/.local/share/chezmoi/bin/executable_update_all_plugins /root/bin/update_all_plugins
RUN mkdir -p /root/.vim/autoload && \
    wget -O - https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim > /root/.vim/autoload/plug.vim && \
    chmod +x /root/bin/* && \
    /root/bin/update_all_plugins

COPY home/ /root
RUN echo "export EMAIL=scott+tst@schlesier.ca" > ~/.zsh/shell_environment.zsh #hack in shell_environment

RUN chmod 0700 /root/.local/share/chezmoi
RUN chezmoi apply

CMD /usr/bin/zsh
