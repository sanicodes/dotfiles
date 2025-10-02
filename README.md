# DOTFILES
# Prerequisites
 - [nvim](https://neovim.io/)
 - [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
 - [kitty](https://sw.kovidgoyal.net/kitty/)
# How To's
## Get Started
  1. Install prerequisites and familiarize os folder structures.
  2. **BACKUP**  and *Delete/Rename* existing configurations for some apps you want to modify.
  3. Generate [Symlinks](https://github.com/sanicodes/dotfiles/edit/main/README.md#how-to-create-symbolic-links-in-windows-linux-and-macos) for chosen app folders.
  4. Check the configurations and folders. 

## How to Create Symbolic Links in Windows, Linux, and macOS

- A symbolic link (also known as a symlink) is a file-system object that points to another file or directory. It allows you to access the target file or directory through the link, much like a shortcut. It makes maintaining a specific configuration to git much easier.
---
### Windows

In Windows, symbolic links can be created using the `mklink` command in the Command Prompt.

#### Steps:

1. **Open Command Prompt as Administrator:**

   - Click on the **Start** menu.
   - Type `cmd`.
   - Right-click on **Command Prompt** and select **Run as administrator**.

2. **Use the `mklink` Command:**

   The basic syntax is:

   ```bash
   mklink [options] <Link> <Target>
   ```

   - `<Link>`: The name of the symbolic link you want to create.
   - `<Target>`: The path to the target file or directory.

#### Examples:

- **Create a symbolic link to a file:**

  ```bash
  mklink "C:\path\to\link.txt" "C:\path\to\target.txt"
  ```

- **Create a symbolic link to a directory:**

  ```bash
  mklink /D "C:\path\to\link_folder" "C:\path\to\target_folder"
  ```

- **Create a hard link to a file:**

  ```bash
  mklink /H "C:\path\to\link.txt" "C:\path\to\target.txt"
  ```

#### Options:

- `/D`: Creates a directory symbolic link. Default is a file symbolic link.
- `/H`: Creates a hard link instead of a symbolic link.
- `/J`: Creates a Directory Junction.

**Note:** Administrative privileges are required to create symbolic links in Windows.

---

### Linux

In Linux, the `ln` command is used to create links.

#### Steps:

1. **Open Terminal.**

2. **Use the `ln -s` Command:**

   The basic syntax is:

   ```bash
   ln -s [options] <Target> <Link>
   ```

   - `<Target>`: The path to the target file or directory.
   - `<Link>`: The name of the symbolic link you want to create.

#### Examples:

- **Create a symbolic link to a file:**

  ```bash
  ln -s /path/to/target.txt /path/to/link.txt
  ```

- **Create a symbolic link to a directory:**

  ```bash
  ln -s /path/to/target_folder /path/to/link_folder
  ```

- **Forcefully create a symbolic link (overwrite existing link):**

  ```bash
  ln -sf /path/to/target /path/to/link
  ```

#### Options:

- `-s`: Creates a symbolic link.
- `-f`: Forces the creation by removing existing files.

**Note:** You may need to use `sudo` if you lack necessary permissions.

---

### macOS

On macOS, symbolic links are created similarly to Linux since it's a Unix-based system.

#### Steps:

1. **Open Terminal.**

2. **Use the `ln -s` Command:**

   The syntax is the same as in Linux:

   ```bash
   ln -s [options] <Target> <Link>
   ```

#### Examples:

- **Create a symbolic link to a file:**

  ```bash
  ln -s /path/to/target.txt /path/to/link.txt
  ```

- **Create a symbolic link to a directory:**

  ```bash
  ln -s /path/to/target_folder /path/to/link_folder
  ```

**Note:** While you can also create aliases in Finder, they are not the same as Unix symbolic links and may not work the same way in all applications.

---

### Additional Information

- **Checking Symbolic Links:**

  - **Windows:** Use `dir` to list and check links.
  - **Linux/macOS:** Use `ls -l` to display symbolic links (they typically show with an `->` pointing to the target).

- **Removing Symbolic Links:**

  - **Windows:** Use `del` for files or `rmdir` for directories.
  - **Linux/macOS:** Use `rm` for both files and directories (symbolic links).

- **Permissions:**

  Ensure you have the necessary permissions to create symbolic links in the target directory.

---

By following these instructions, you should be able to create symbolic links on your operating system of choice.

---

## IMPORTANT REFERENCES
- [How to install zsh on windows](https://medium.com/@leomaurodesenv/setting-up-your-git-bash-zsh-terminals-on-windows-fa94871f440d)
- [Nerd Fonts](https://www.nerdfonts.com/font-downloads)
- [Dotfiles tutorials](https://dotfiles.github.io/)
- [INSTALL P10k - OHMYZSH](https://itsfoss.com/zsh-ubuntu/)
- [Maple Font](https://github.com/subframe7536/maple-font/releases)
 
