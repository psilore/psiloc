package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
)

type Action struct {
	Name        string
	Description string
	Run         func() error
}

func printColor(colorCode string, format string, a ...interface{}) {
	fmt.Printf("\033[%sm%s\033[0m\n", colorCode, fmt.Sprintf(format, a...))
}

func printMessage(msg string) {
	printColor("0;32", "[INFO] %s", msg)
}

func printError(msg string) {
	printColor("0;31", "[ERROR] %s", msg)
}

func runBashCommand(cmdString string) error {
	cmd := exec.Command("bash", "-c", cmdString)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}

func runScript(scriptName string, args ...string) error {
	cmdArgs := append([]string{"-c", fmt.Sprintf("\"$@\"")}, "--", filepath.Join("scripts", scriptName))
	cmdArgs = append(cmdArgs, args...)
	cmd := exec.Command("bash", cmdArgs...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}

func main() {
	reader := bufio.NewReader(os.Stdin)

	actions := []Action{
		{"Install required packages", "Updates apt and installs packages from scripts/required-packages", func() error {
			printMessage("Installing required packages...")
			return runBashCommand(`sudo apt-get update && if [ -f "scripts/required-packages" ]; then xargs -a "scripts/required-packages" sudo apt-get install -y; else echo "[ERROR] File not found"; fi`)
		}},
		{"Remove unwanted packages", "Removes packages listed in scripts/unwanted-packages", func() error {
			printMessage("Removing unwanted packages...")
			return runBashCommand(`if [ -f "scripts/unwanted-packages" ]; then xargs -a "scripts/unwanted-packages" sudo apt-get remove -y; fi; sudo apt-get autoremove -y; sudo apt-get autoclean -y`)
		}},
		{"Install Neovim", "Installs latest stable Neovim from tarball", func() error {
			printMessage("Installing Neovim...")
			return runBashCommand(`wget -qO /tmp/nvim-linux-x86_64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && sudo rm -rf /opt/nvim-linux-x86_64 && sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz && rm /tmp/nvim-linux-x86_64.tar.gz && sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim`)
		}},
		{"Setup cron backup job", "Sets up user cron job for backup.sh", func() error {
			fmt.Print("Enter hostname for backup: ")
			host, _ := reader.ReadString('\n')
			host = strings.TrimSpace(host)
			if host == "" {
				printError("Hostname is required")
				return nil
			}
			printMessage("Setting up cron backup job...")
			return runBashCommand(fmt.Sprintf(`cp scripts/backup.sh ~/backup.sh && (crontab -u "$USER" -l 2>/dev/null; echo "0 0 */1 * * /home/$USER/backup.sh %s") | crontab -u "$USER" -`, host))
		}},
		{"Install 1Password", "Downloads and installs 1Password", func() error {
			return runBashCommand(`wget -qO ~/Downloads/1password-latest.deb https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb && sudo apt-get update && sudo apt-get install ~/Downloads/1password-latest.deb -y`)
		}},
		{"Install Google Chrome", "Downloads and installs Google Chrome", func() error {
			return runBashCommand(`wget -qO ~/Downloads/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo apt-get update && sudo apt-get install ~/Downloads/google-chrome-stable_current_amd64.deb -y`)
		}},
		{"Install Tailscale", "Installs Tailscale", func() error {
			return runBashCommand(`curl -fsSL https://tailscale.com/install.sh | sh`)
		}},
		{"Install Terraform", "Installs Terraform via HashiCorp repo", func() error {
			return runBashCommand(`wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list && sudo apt-get update && sudo apt-get install terraform -y`)
		}},
		{"Install Docker", "Installs Docker Engine", func() error {
			return runBashCommand(`sudo install -m 0755 -d /etc/apt/keyrings && sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && sudo chmod a+r /etc/apt/keyrings/docker.asc && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y`)
		}},
		{"Install VS Code", "Installs Visual Studio Code", func() error {
			return runBashCommand(`curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" && sudo apt-get update && sudo apt-get install code -y`)
		}},
		{"Install Oh-My-Zsh", "Installs Oh-My-Zsh", func() error {
			return runBashCommand(`sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`)
		}},
		{"Install FuzzyFinder (fzf)", "Installs fzf from git", func() error {
			return runBashCommand(`git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install`)
		}},
		{"Install Zsh plugins", "Installs useful Zsh plugins", func() error {
			return runBashCommand(`if [ -d "$HOME/.oh-my-zsh" ]; then git clone --depth 1 -- https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab && git clone --depth 1 -- https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && git clone --depth 1 -- https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete; else echo "[ERROR] Oh-My-Zsh not installed"; fi`)
		}},
		{"Setup LazyVim", "Sets up LazyVim for Neovim", func() error {
			return runBashCommand(`if command -v nvim >/dev/null 2>&1; then [ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%Y%m%d_%H%M%S)"; git clone https://github.com/LazyVim/starter "$HOME/.config/nvim" && rm -rf "$HOME/.config/nvim/.git"; else echo "[ERROR] Neovim not installed"; fi`)
		}},
		{"Install Nerd Fonts", "Installs Source Code Pro Nerd Fonts", func() error {
			return runBashCommand(`wget -qO ~/Downloads/SourceCodePro.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip && unzip -o ~/Downloads/SourceCodePro.zip -d ~/Downloads/SourceCodePro && mkdir -p ~/.local/share/fonts && cp ~/Downloads/SourceCodePro/* ~/.local/share/fonts/ && fc-cache -fv`)
		}},
		{"Install Ghostty terminal", "Installs Ghostty via Snap", func() error {
			return runBashCommand(`if ! command -v snap >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y snapd; fi; sudo snap install ghostty --classic`)
		}},
		{"Set Zsh as default shell", "Changes default shell to Zsh", func() error {
			return runBashCommand(`chsh -s "$(which zsh)"`)
		}},
		{"Workstation Security Hardening", "Runs harden.sh", func() error {
			return runScript("harden.sh")
		}},
		{"Run Local Security Audit", "Runs audit.sh", func() error {
			return runScript("audit.sh")
		}},
		{"Revert Security Hardening", "Runs unharden.sh", func() error {
			return runScript("unharden.sh")
		}},
		{"Refresh shell", "Reloads current shell config", func() error {
			return runBashCommand(`if [ -f "$HOME/.zshrc" ]; then exec zsh; elif [ -f "$HOME/.bashrc" ]; then exec bash; else exec $SHELL; fi`)
		}},
	}

	for {
		printColor("1;34", "\n========================================")
		printColor("1;34", "     System Setup Menu (psiloc)         ")
		printColor("1;34", "========================================")

		for i, action := range actions {
			fmt.Printf("  %d) %s\n", i+1, action.Name)
		}
		fmt.Printf("  %d) Install ALL\n", len(actions)+1)
		fmt.Println("  0) Exit")
		fmt.Print("\nEnter your choice: ")

		input, err := reader.ReadString('\n')
		if err != nil {
			break
		}
		input = strings.TrimSpace(input)

		if input == "0" {
			printMessage("Exiting...")
			break
		}

		choice, err := strconv.Atoi(input)
		if err != nil || choice < 0 || choice > len(actions)+1 {
			printError("Invalid choice. Please enter a number from the menu.")
			continue
		}

		if choice == len(actions)+1 {
			printMessage("Running all installation steps...")
			for _, action := range actions {
				fmt.Printf("\n--- Running: %s ---\n", action.Name)
				if err := action.Run(); err != nil {
					printError(fmt.Sprintf("Failed: %v", err))
				}
			}
			continue
		}

		action := actions[choice-1]
		fmt.Printf("\n--- Running: %s ---\n", action.Name)
		if err := action.Run(); err != nil {
			printError(fmt.Sprintf("Failed: %v", err))
		}
	}
}
