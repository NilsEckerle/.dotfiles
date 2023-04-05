(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
(package-refresh-contents)
(package-install 'use-package))

(custom-set-variables
;; custom-set-variables was added by Custom.
;; If you edit it by hand, you could mess it up, so be careful.
;; Your init file should contain only one such instance.
;; If there is more than one, they won't work right.
'(custom-safe-themes
  '("f366d4bc6d14dcac2963d45df51956b2409a15b770ec2f6d730e73ce0ca5c8a7" "8b6506330d63e7bc5fb940e7c177a010842ecdda6e1d1941ac5a81b13191020e" "1cae4424345f7fe5225724301ef1a793e610ae5a4e23c023076dc334a9eb940a" default))
'(package-selected-packages
  '(emacsql-sqlite-module emacsql-sqlite-builtin sqlite org-roam sqlite3 emacsql-mysql emacsql-sqlite toc-org org-rainbow-tags doom-themes auto-complete org-auto-tangle)))

(use-package helm
  :ensure t
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files))
  :config
  (setq helm-M-x-fuzzy-match t)
  (setq helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match t)
  (setq helm-semantic-fuzzy-match t
        helm-imenu-fuzzy-match t)
  )

(use-package auto-complete
  :ensure t
  :config
  (ac-config-default))

(use-package org-auto-tangle
:defer t
:hook (org-mode . org-auto-tangle-mode)
:after org
:config
(setq org-auto-tangle-default t))

(use-package org-roam
:ensure t
:custom
(org-roam-directory "~/Wissen")
:bind (("C-c n l" . org-roam-buffer-toggle)
       ("C-c n f" . org-roam-node-find)
       ("C-c n i" . org-roam-node-insert))
:config
(org-roam-setup))

(use-package toc-org
  :ensure t)

(require 'dashboard)
(setq dashboard-banner-logo-title "Welcome back, Nils!")
(dashboard-setup-startup-hook)

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

(setq dashboard-center-content t)

(add-hook 'org-mode-hook 'toc-org-mode)

(add-hook 'org-mode-hook 'org-indent-mode)

(menu-bar-mode -1)

(tool-bar-mode -1)

;; relative line numbers
(global-display-line-numbers-mode)

;; Make line numbers relative
(setq display-line-numbers-type 'relative)

(add-hook 'text-mode-hook 'visual-line-mode)

(add-to-list 'custom-theme-load-path ".emacs.d/themes/")

(load-theme 'doom-opera t)
