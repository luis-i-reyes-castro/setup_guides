# 2025 MacOS for Python
This guide will help you set up your MacOS system. It installs Brew, GIT, a Python virtual environment, and some Python ML packages.

## Install Essential Tools

### Install Brew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade
brew cleanup
```

### Install GIT
```bash
brew install git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global credential.helper store
git config --global core.autocrlf input
```
In addition, if you going to work with CSV files in a git repository, make sure to add a `.gitattributes` file to the repository with the following line:
```
*.csv text eol=lf
```

### Install Python and Pip
```bash
brew install python3
```
To verify installation:
```bash
python3 --version
pip3 --version
```

Create a virtual environment named `pe` and activate it:
```bash
python3 -m venv pe
source pe/bin/activate
```
If for some reason you need to deactivate the environment:
```bash
deactivate
```

### Install Python Packages
Install essential Python ML packages.
```bash
pip install --upgrade numpy scipy pandas scikit-learn matplotlib seaborn pillow torch
```
Install popular LLM APIs.
```bash
pip install --upgrade anthropic mistralai openai
```

## Customize Shell
Copy or append the code in [`.zshrc`](.zshrc) to your `~/.zshrc`.

## Additional Resources
* [MacOS Shortcuts](macos_shortcuts.md)
* [MacOS Spanish Keyboard Symbols](macos_spanish.md)
