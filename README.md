# Machine Setup

## Installation

### What I need to do...

1. First, make sure to run:
```
sudo apt update -y && sudo apt upgrade -y
```
2. Now install `git` and `ansible`:
```
sudo apt install git gh ansible -y
```
3. Clone the repo:
```
git clone https://github.com/Phelz/machine_setup
```
4. Then run the ansible playbook via:
```
sudo ansible-playbook -v setup.yml --become-user=USERNAME --ask-become-pass
```
replacing `USERNAME`. The `--ask-become-pass` option prompts you for your password, and will enable you to authenticate yourself, as some processes require run-time validation.

Since this is my laptop, I'd need to
- Install GPU drivers.
- Link Google account.
- Setup an SSH Key and add it to my github account. This part is done by
    1. Generating an SSH Key: `ssh-keygen -t ed25519 -C "philogeee@gmail.com"`
    2. Checking the ssh agent: `eval "$(ssh-agent -s)"`
    3. Adding the private key to the agent: `ssh-add ~/.ssh/KEY_ID`
    4. Using `gh auth login` alongside a personal access token or via browser, setting SSH as the preferred protocol.
    5. Add the key using `gh ssh-key add ~/.ssh/KEY_ID.pub --title "YOUR_TITLE"`
   replacing `KEY_ID` with your key and `YOUR_TITLE' with whatever name you want.

I recommend doing this process before cloning the repo. Then you can clone via SSH (instead of having to switch the HTTPS remote later on when trying to edit the repo).

- Run commmand `ansible-playbook setup.yml --extra-vars "target_user=username" -v` replacing "username". 

***Might be asked for a password a couple times during the installation.***

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



