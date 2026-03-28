install: install-calc install-quick-calc

install-calc: calculator.desktop
	cp ~/scripts/calculator/calculator.desktop ~/.local/share/applications/calculator.desktop

install-quick-calc: quick-calculator.desktop
	cp ~/scripts/calculator/quick-calculator.desktop ~/.local/share/applications/quick-calculator.desktop

uninstall:
	rm ~/.local/share/applications/calculator.desktop
	rm ~/.local/share/applications/quick-calculator.desktop

.PHONY: install uninstall
