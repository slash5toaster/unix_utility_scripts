
# Unix/Linux Utilties

## dotfiles

This is a set of dotfiles, with the dot removed
They should be renamed from `whatever` to `~/.whatever` and live at the root of your home directory

e.g.  rename `gitconfig` to `~/.gitconfig`

Most identifying info is removed , so ***please*** check them before using
The `ssh/config` file is a template for your `~/.ssh/config` file.  You *must* replace your `<unix_id>` with your unix id for this to work.

## Bin files

A number of tools to do various things on the command line, you can install these in `~/.local/bin` or `~/.bin`, just be sure to update your path statement e.g. ```export PATH=~/.local/bin/:$PATH```

1. sha_manifest - creates a manifest of all files in a directory using the sha1sum of the files. Symlinks are added just for completeness
1. sha_dups - finds duplicates of files in a directory tree based on the manifest file. This needs to have parallel installed <https://www.gnu.org/software/parallel/> or `ml parallel`
1. git_infostring.sh - for use in PS1 variables. Gives information about git repo while in the directory, this should be part of your `.bashrc` to update your prompt like so

        ```clyde:~/unix_utility_scripts (main 0S-1U) $```

1. virtualenv_setup.sh - setups a python virtual enviroment in the existing directory.  **requires** a requirements.txt that includes any modules to be installed.

## Slurm scripts

Sample slurm submission scripts

1. `Slurm_Examples/Slurm_array_Reading_manifest.sb` reads a manifiest file and builds an array job to execute on a list of files
1. `Slurm_Examples/Slurm_Array_Math.sb` using calculations based on the `$SLURM_ARRAY_TASK_ID` to change parameters between runs.
