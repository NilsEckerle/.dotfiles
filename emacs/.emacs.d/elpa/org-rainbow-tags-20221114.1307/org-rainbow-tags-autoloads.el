;;; org-rainbow-tags-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "org-rainbow-tags" "org-rainbow-tags.el" (0
;;;;;;  0 0 0))
;;; Generated autoloads from org-rainbow-tags.el

(autoload 'org-rainbow-tags-mode "org-rainbow-tags" "\
Colorize org tags automatically to make them visually distinguishable.

This is a minor mode.  If called interactively, toggle the
`Org-Rainbow-Tags mode' mode.  If the prefix argument is
positive, enable the mode, and if it is zero or negative, disable
the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `org-rainbow-tags-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\(fn &optional ARG)" t nil)

(register-definition-prefixes "org-rainbow-tags" '("org-rainbow-tags-"))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; org-rainbow-tags-autoloads.el ends here
