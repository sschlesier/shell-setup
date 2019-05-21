FROM fedora

RUN dnf -y install neovim python3 ddgr zsh git wget 
RUN dnf -y install python

COPY . /root/
RUN mv /root/antibody /usr/local/bin && mv /root/chezmoi /usr/local/bin/
RUN antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

RUN chmod 0700 ~/.local/share/chezmoi
RUN chezmoi apply

CMD /usr/bin/zsh
