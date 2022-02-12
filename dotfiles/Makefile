# By convention, the first target will be the default, i.e. it will be executed
# when running `make` without any arguments.
#
# The .PHONY stuff is just something I picked up from:
# https://github.com/tj/mmake

# Create symlinks for all configuration files.
install:
	ln -sf "$$PWD/.gitconfig" "$$HOME/.gitconfig" && \
	ln -sf "$$PWD/settings.json" "$$HOME/.config/Code/User/settings.json"
.PHONY: install

clean:
	rm "$$HOME/.gitconfig" && \
	rm "$$HOME/.config/Code/User/settings.json"
.PHONY: clean
