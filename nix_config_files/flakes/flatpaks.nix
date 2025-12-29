{ ... }: {
	# FLATPAK ONLY CONFIGURATION
	services.flatpak.enable = true;
	services.flatpak.packages = [
		"com.discordapp.Discord"
		"com.github.tchx84.Flatseal"
	];
	services.flatpak.remotes = [
		{
			name = "flathub";
			location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
		}
	];
	# services.flatpak.update = {
	# 	auto = {
	# 		enable = true;
	# 		onCalendar = "weekly";
	# 	};
	# };
	# These options require the nix-flatpak module to be imported
}
