(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

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

;;  (use-package auto-complete
;;    :ensure t
;;    :config
;;    (progn
;;      (ac-config-default)
;;      (add-hook 'emacs-lisp-mode-hook #'auto-complete-mode)))

;;  (global-auto-complete-mode t)

(use-package company
:ensure t
:config
(global-company-mode 1))

(use-package org-auto-tangle
:defer t
:hook (org-mode . org-auto-tangle-mode)
:after org
:config
(setq org-auto-tangle-default t))

(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (cons arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/Wissen")
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: dnd-character-${title}\n")
      :unnarrowed t)
     ("n" "Dungeons&Dragons-roam-template" plain
       "- Name: ${title}\n- Alter: \n- Rasse: \n- Klasse: %^{Klasse}\n- Klassennotiz: \n\n* Stats\ngewürfelt:\n|   |   |   |   |   |   |\n\nHP: \nCurrent HP: \n\n||_____\n| ____ |\n||    ||\n|| AC ||\n||----||\n|| -- || \n||____||\n|______|\n\n\n#+TBLNAME: MainStats\n|-----+-----+-----+-----+-----+-----|\n| str | dex | con | int | cha | wis |\n|-----+-----+-----+-----+-----+-----|\n|     |     |     |     |     |     |\n|-----+-----+-----+-----+-----+-----|\n|     |     |     |     |     |     |\n|     |     |     |     |     |     |\n|-----+-----+-----+-----+-----+-----|\n#+TBLFM: @4=((@2)-10)/2;%.0f\n\n#+TBLNAME: SubStats\n| NAME                              | ATRIBUT | MODIFIRE |\n| Atletisch (athletics)             | str     |          |\n| Tierumgang (animal handling)      | wis     |          |\n| Überleben (survival)              | wis     |          |\n| Beobachtung (perception)          | wis     |          |\n| Menschenkentnis (insight)         | wis     |          |\n| Medizin (medicine)                | wis     |          |\n| Religion (religion)               | int     |          |\n| Arkane Kunde (arcana)             | int     |          |\n| Geschichte (history)              | int     |          |\n| Untersuchen (investigation)       | int     |          |\n| Natur (naure)                     | int     |          |\n| Täuschung (deception)             | cha     |          |\n| performance (performance)         | cha     |          |\n| Einschüchtern (intimidation)      | cha     |          |\n| Überzeugen (persuation)           | cha     |          |\n| Akrobatik (acrobatics)            | dex     |          |\n| Fingerfertigkeit (slight of hand) | dex     |          |\n| Heimlichkeit (stealth)            | dex     |          |\n#+TBLFM: $3='(if (equal $2 \"str\" ) remote(MainStats,@4$1) (if (equal $2 \"wis\") remote(MainStats,@4$6) (if (equal $2 \"int\") remote(MainStats,@4$4) (if (equal $2 \"cha\") remote(MainStats,@4$5) (if (equal $2 \"dex\") remote(MainStats,@4$2) \"MODIFIRE\")))))\n\n* Inventar\nGeld\n|-----------------+--------------+------------------+-----------------+------------------|\n| Platin 1p = 10G | Gold 1G = 1G | Electrum 1G = 2e | Silver 1G = 10s | Kupfer 1G = 100k |\n|-----------------+--------------+------------------+-----------------+------------------|\n|                 |              |                  |                 |                  |\n|-----------------+--------------+------------------+-----------------+------------------|\n\nInventar\n|------------------------+-------+------+--------------------|\n| NAME                   | MENGE | WERT | NOTIZ              |\n|------------------------+-------+------+--------------------|\n|                        |       |      |                    |\n|                        |       |      |                    |\n|                        |       |      |                    |\n"
       :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: dnd-character-${title}\n")
       :unnarrowed t)
     ("b" "Buchnotizen" plain
      "\n* Source\n\nAutor: %^{Autor}\nTitel: ${title}\nJahr: %^{Jahr}\n\n* Summary\n\n%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     )
   )
   :bind (("C-c n l" . org-roam-buffer-toggle)
          ("C-c n f" . org-roam-node-find)
          ("C-c n i" . org-roam-node-insert)
          ("C-c n I" . org-roam-node-insert-immediate))
   :config
   (org-roam-setup))

(use-package toc-org
  :ensure t)

(require 'dashboard)
(setq dashboard-banner-logo-title "Welcome back, Nils!")
(dashboard-setup-startup-hook)

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

(use-package org-download
:ensure t
:defer t
:config
(setq-default org-download-image-dir "./img")
(setq-default org-download-heading-lvl nil)
(setq-default org-download-timestamp "%Y%m%d-%H%M%S_")
(setq-default org-image-actual-width 600)
(setq-default org-download-screenshot-method "maim -s %s"))

(use-package multiple-cursors
:ensure t
:bind (("C-c m c" . 'mc/edit-lines)
       ("C-c m n" . 'mc/mark-next-like-this)
       ("C-c m p" . 'mc/mark-previous-like-this)
       ("C-c m a" . 'mc/mark-all-like-this)))

(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode))

(setq dashboard-center-content t)

(add-hook 'org-mode-hook 'toc-org-mode)

(add-hook 'org-mode-hook 'org-indent-mode)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:slant normal :weight normal :height 98 :width normal))))
 '(org-level-1 ((t (:inherit outline-1 :height 2.5 :foreground "#42d6a4"))))
 '(org-level-2 ((t (:inherit outline-2 :height 2.3 :foreground "#08cad1"))))
 '(org-level-3 ((t (:inherit outline-3 :height 2.1 :foreground "#59adf6"))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.9 :foreground "#9d94ff"))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.7 :foreground "#c780e8"))))
 '(org-level-6 ((t (:inherit outline-6 :height 1.5 :foreground "#ff6961"))))
 '(org-level-7 ((t (:inherit outline-7 :height 1.3 :foreground "#ffb480"))))
 '(org-level-8 ((t (:inherit outline-8 :height 1.1 :foreground "#f8f38d")))))

(setq org-display-inline-images t)
(setq org-startup-with-inline-images t)

(setq org-src-block-faces '(("elisp"  (:background "#311111" :extend t))
                            ("python" (:background "#342911" :extend t))
                            ("c++"    (:background "#3f3411" :extend t))
                            ("lua"    (:background "#0f3013" :extend t))))

(defvar hexcolour-keywords
 '(("#[abcdef[:digit:]]\\{6\\}"
    (0 (put-text-property (match-beginning 0)
                          (match-end 0)
                          'face (list :background 
                                      (match-string-no-properties 0)))))))
(defun hexcolour-add-to-font-lock ()
  (font-lock-add-keywords nil hexcolour-keywords))
(add-hook 'org-mode-hook 'hexcolour-add-to-font-lock)

(menu-bar-mode -1)

(tool-bar-mode -1)

;; relative line numbers
(global-display-line-numbers-mode)

;; Make line numbers relative
(setq display-line-numbers-type 'relative)

(add-hook 'text-mode-hook 'visual-line-mode)

(add-to-list 'custom-theme-load-path ".emacs.d/themes/")

(load-theme 'doom-opera t)
