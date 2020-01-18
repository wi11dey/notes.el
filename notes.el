;;; notes.el --- Generate and auto-title untitled buffers -*- lexical-binding: t -*-

;; Author: Will Dey
;; Version: 1.0.0
;; Package-Requires: ((major-extension "1.0.0"))
;; Homepage: https://github.com/wi11dey/notes.el
;; Keywords: keywords

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;; Generate README:
;;; Commentary:

;; Generate and auto-title untitled buffers

;;; Code:

;; TODO Make title `heading-8' face automatically with font-lock

(require 'major-extension)

(defgroup notes nil
  "")

(defcustom notes-initial-buffer-name "Note"
  ""
  :type 'string)

(defcustom notes-initial-buffer-mode 'text-mode
  ""
  :type 'function)

(defcustom notes-default-directory "~/"
  ""
  :type 'directory)

(defvar notes-new-hook nil
  "")



(defun notes-update-auto-save ()
  )

(defun notes-get-buffer-name ()
  (let (name)
    (save-excursion
      (goto-char (point-min))
      (forward-line)
      (setq name (buffer-substring-no-properties (point-min) (point))
	    name (string-trim name)))
    (if (string-empty-p name)
	notes-initial-buffer-name
      name)))



(defvar-local notes-major-mode-extension nil
  "")

(defun notes-post-command ()
  (rename-buffer (concat (notes-get-buffer-name)
			 (when notes-major-mode-extension
			   ".")
			 notes-major-mode-extension)
		 'unique)
  (notes-update-auto-save))

(defun notes-after-change-major-mode ()
  ""
  (setq notes-major-mode-extension (major-extension))
  (notes-post-command))

(defun notes-save-buffer (&optional arg)
  ""
  (interactive "p")
  ;; TODO Move auto-save
  (notes-mode -1)
  (save-buffer arg))

(define-minor-mode notes-mode
  "Notes"
  :lighter " Note"
  :keymap '(([remap save-buffer] . notes-save-buffer))
  ;; Teardown:
  (remove-hook 'post-command-hook #'notes-post-command :local)
  (put         'post-command-hook 'permanent-local nil)
  (remove-hook 'change-major-mode-hook #'notes-mode)
  (put         'change-major-mode-hook 'permanent-local nil)
  (remove-hook 'after-change-major-mode-hook #'notes-after-change-major-mode :local)
  (put         'after-change-major-mode-hook 'permanent-local nil)
  (when notes-mode
    (add-hook 'post-command-hook #'notes-post-command nil :local)
    (put      'post-command-hook 'permanent-local t)
    (add-hook 'change-major-mode-hook #'notes-mode nil :local)
    (put      'change-major-mode-hook 'permanent-local t)
    (add-hook 'after-change-major-mode-hook #'notes-after-change-major-mode nil :local)
    (put      'after-change-major-mode-hook 'permanent-local t)))
(put 'notes-mode 'permanent-local t)



;;;###autoload
(defun note (title)
  ""
  (interactive "MNote title: ")
  (switch-to-buffer (generate-new-buffer notes-initial-buffer-name))
  (setq default-directory (or notes-default-directory
			      default-directory))
  (funcall notes-initial-buffer-mode)
  (notes-mode)
  (insert title "\n\n")
  (run-hooks 'notes-new-hook))

(provide 'notes)
