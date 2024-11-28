# Machine Setup

## Installation

### What I need to do...

Since this is my laptop, I'd need to
- Install GPU drivers.
- Link Google account.
- Setup an SSH Key and add it to my github account. This part is done by
    1. Generating an SSH Key.
    2. Using `gh auth login` along with my personal access token.

- Run commmand `ansible-playbook playbook.yml -e "target_user=username"` replacing "username".

## What I did...



###  1. Configuring the XDG_CONFIG_HOME

Set the `$XDG_CONFIG_HOME` directory to be `$HOME/.config` so that all dotfile configurations are there. To do so, add these lines to the `.zshenv` file in the `$HOME` directory:

```
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"
```

### 2. What Ansible needs to do...

#### 2.1 Installing `zsh`, *nerdfonts*, 

`git clone https://github.com/tmux-plugins/tpm $XDG_CONFIG_HOME/tmux/plugins/tpm`



