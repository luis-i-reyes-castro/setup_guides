# 2025 MacOS Python ML Dev Setup Guide
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
Git is essential for version control.
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

## Set Up Python Environment

### Install Python and Pip
Install Python, Pip, and the `venv` module.
```bash
brew install python3
```
Verify installation.
```bash
python3 --version
pip3 --version
```

### Create and Activate a Python Virtual Environment
Create a virtual environment named `pe` and activate it.
```bash
python3 -m venv pe
source pe/bin/activate
```
### Install Python Packages
Install essential Python ML packages.
```bash
pip install --upgrade numpy scipy pandas scikit-learn matplotlib seaborn pillow torch
```
Install OpenCV and tesseract OCR.
```bash
sudo apt-get install python3-opencv tesseract-ocr
pip install opencv-python pytesseract
```
Install other useful packages.
```bash
pip install tiktoken tqdm
```
Install tkinter for GUI development (useful for making labeling UIs).
```bash
sudo apt install python3-tk
```
Install popular LLM APIs.
```bash
pip openai mistralai deepseek langchain langchain-community langchain-openai
```

### Automate Python Environment Activation
To automatically activate the `pe` environment when opening a terminal, add the activation command to your `.bashrc` file.
```bash
echo 'source ~/pe/bin/activate' >> ~/.zshrc
```
Reload the .bashrc file to apply the changes.
```bash
source ~/.bashrc
```
Alternatively, you may simply close and re-open the terminal.

### Deactivate the Environment
If for some reason you need to deactivate the environment, you can easily do it as follows.
```bash
deactivate
```
