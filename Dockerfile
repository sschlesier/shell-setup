FROM fedora as BASE
RUN dnf -y install neovim zsh git wget tmux unzip
COPY ulb/ /usr/local/bin
RUN chmod +x /usr/local/bin/*

#improve build times pre-build shell plugins
FROM BASE as ANTIBODY
COPY home/.local/share/chezmoi/dot_zsh/pre_compinit_plugins.txt /root/.zsh/pre_compinit_plugins.txt
COPY home/.local/share/chezmoi/dot_zsh/post_compinit_plugins.txt /root/.zsh/post_compinit_plugins.txt
RUN antibody bundle < ~/.zsh/pre_compinit_plugins.txt && \
    antibody bundle < ~/.zsh/post_compinit_plugins.txt

#improve build times pre-build vim plugins
FROM BASE as VIMPLUG
RUN mkdir -p /root/.vim/autoload && \
    wget -O - https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim > /root/.vim/autoload/plug.vim
COPY home/.local/share/chezmoi/dot_vimrc /root/.vimrc
COPY home/.local/share/chezmoi/private_dot_config/nvim/init.vim /root/.config/nvim/init.vim
RUN nvim +PlugUpdate +qall

#improve build times pre-build tmux plugins
FROM BASE as TPM
ENV TMUX_PLUGIN_MANAGER_PATH=/root/.tmux/plugins
RUN git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_MANAGER_PATH/tpm"
COPY home/.local/share/chezmoi/dot_tmux.conf /root/.tmux.conf
RUN /root/.tmux/plugins/tpm/bin/install_plugins

FROM BASE as FINAL
RUN dnf -y install neovim python3 ddgr zsh git wget python tmux unzip fzf fd-find the_silver_searcher ruby exa hyperfine
COPY --from=ANTIBODY /root/.cache/antibody /root/.cache/antibody
COPY --from=VIMPLUG /root/.vim/plugged /root/.vim/plugged
COPY --from=TPM /root/.tmux /root/.tmux

ENV TERM=xterm-256color
RUN sed -i 's/\/bin\/bash$/\/usr\/bin\/zsh/' /etc/passwd
COPY home/ /root
RUN mkdir -p /root/.zsh && \
    echo "export EMAIL=scott+tst@schlesier.ca" > ~/.zsh/shell_environment.zsh #hack in shell_environment

RUN chmod 0700 /root/.local/share/chezmoi
RUN chezmoi apply

CMD /usr/bin/zsh
