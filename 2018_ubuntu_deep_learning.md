# 2018 Ubuntu for Deep Learning

This manual contains instructions for setting up a computer with an NVIDIA CUDA-capable video card to run deep learning software. 

### Step 1: Install Ubuntu Without the Graphics Card

Please install the US English version. 

### Step 2: Install the NVIDIA Display Drivers

As of early October 2017, the latest long-lived version is `nvidia-384`. However, we still recommend you install `nvidia-375`. 
```markdown
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt-get update
sudo apt-get install nvidia-375
```

Now you should shut down the computer and physically install the graphics card. In addition, don't forget to change the primary display's DVI input from the mainboard's DVI output to the video card's DVI output. Also, you may now connect additional displays to your computer through the video card's HDMI outputs. 

### Step 3: Install CUDA

As of early October 2017, the latest CUDA version is 9.0. However, this CUDA version is not compatible with any Tensorflow version. Therefore, we recommend you install CUDA 8.0, and in particular we recommend you download the Debian file installer:
```markdown
cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64.deb
```

Assuming you copy the file to your `~/Downloads/` directory you may install the library as follows: 
```markdown
cd ~/Downloads/
sudo dpkg -i cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64.deb
sudo apt-get update
sudo apt-get install cuda
```

To complete the instalation you will need to edit and add environment variables: 
```markdown
sudo gedit /etc/environment
```

In particular:

* Edit variable `PATH` by adding to it directory `/usr/local/cuda/bin`.
* Create variable `LD_LIBRARY_PATH` and add to it directory `/usr/local/cuda/lib64`.
* Create variable `CUDA_HOME` and add to it directory `/usr/local/cuda`.

Now reboot the computer and verify the installation of the Nvidia CUDA Compiler (NVCC) by issuing: 
```markdown
which nvcc
```
This command should print `/usr/local/cuda/bin/nvcc`. 

### Step 4: Download CUDNN-6

Download CUDNN-6 from https://developer.nvidia.com/cudnn and then untar it.
```markdown
cd ~/Downloads
tar -xzvf cudnn-8.0-linux-x64-v6.0.tgz
```

Copy the files to the appropiate directories inside CUDA folder
```markdown
sudo cp cuda/include/cudnn.h /usr/local/cuda/include/cudnn.h
sudo cp cuda/lib64/libcudnn.so.6.0.21 /usr/local/cuda/lib64/libcudnn.so.6.0.21
sudo cp cuda/lib64/libcudnn_static.a /usr/local/cuda/lib64/libcudnn_static.a
cd /usr/local/cuda/lib64
```

Create symbolic links
```markdown
sudo ln -s libcudnn.so.6.0.21 libcudnn.so.6
sudo ln -s libcudnn.so.6 libcudnn.so
```

### Step 5: Install Python-3 and PIP-3

```markdown
sudo apt-get install python3 python3-dev python3-pip
sudo -H pip3 install --upgrade pip
```

### Step 6: Install Numpy, Scipy, Pandas, Sklearn, Tensorflow and Keras
```markdown
sudo -H pip3 install numpy scipy pandas sklearn
sudo -H pip3 install tensorflow-gpu
sudo -H pip3 install pickle h5py
sudo -H pip3 install keras
sudo apt-get install graphviz
```

### Step 7: Install Spyder
```markdown
sudo apt-get install spyder3
sudo apt-get remove spyder3
sudo -H pip3 install -U spyder
```

### Step 8-A: Install GIT
```markdown
sudo apt-get install git
```
### Step 8-B: Setup GIT:
Copying the contents of the attached file 'git-bashrc-hack.txt' to your ~/.bashrc file. Remember to modify the directories of the 'git-completion.bash' and 'git-prompt.sh' to point to the appropriate files. I.e.: 

```markdown
"source ~/Dropbox/Code/scripts/git-completion.bash" -> "source */where_your_bash_and_sh_files_are/git-completion.bash"
"source ~/Dropbox/Code/scripts/git-prompt.sh" -> "source */where_your_bash_and_sh_files_are/git-prompt.sh"
```
