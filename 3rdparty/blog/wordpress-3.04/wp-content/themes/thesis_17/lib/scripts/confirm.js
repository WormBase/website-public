function confirm_choice(kind, type) {
	if (kind == "default")
		var confirmed = confirm("Whoa there! Are you sure you want to restore "+type+" Options defaults? Unless you've made a backup of your current settings, this cannot be undone!");
	else if (kind == "upload")
		var confirmed = confirm("Are you sure you want to upload and overwrite "+type+" Options? Unless you've made a backup of your current settings, this cannot be undone!");
	if (confirmed) return true;
	else return false;
}