;;; compat-tests.el --- Tests for compat.el      -*- lexical-binding: t; -*-

;; Copyright (C) 2021, 2022, 2023 Free Software Foundation, Inc.

;; Author: Philip Kaludercic <philipk@posteo.net>
;; Package-Requires: ((emacs "28.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Tests for compatibility functions from compat.el.
;;
;; Note that not all functions have tests (yet), for the most part
;; because it is difficult to create a reproducible environment to
;; test these in or their tests are trivial -- or a combination of
;; both.
;;
;; Tests are welcome, but until then anyone working on these functions
;; should take care to test these manually.

;;; Code:

(require 'ert)

(require 'compat-macs)

(defvar compat-current-version)
(defun compat--generate-testable (name def-fn install-fn _check-fn attr _type)
  "Generate a more verbose compatibility definition, fit for testing.
See `compat-generate-function' for details on the arguments NAME,
DEF-FN, INSTALL-FN, CHECK-FN, ATTR and TYPE."
  (let* ((realname (or (plist-get attr :realname)
                       (intern (format "compat--%S" name))))
         (feature (plist-get attr :feature))
         (version (or (plist-get attr :version)
                      compat-current-version)))
    `(progn
       (put ',realname 'compat-version ,version)
       (put ',realname 'compat-min-version
            ,(plist-get attr :min-version))
       (put ',realname 'compat-max-version
            ,(plist-get attr :max-version))
       ,(and feature `(require ,feature))
       ,(funcall def-fn realname version)
       ,(funcall install-fn realname version))))

;; For testing: (setq compat--generate-function #'compat--generate-testable)

(defvar compat-testing)
(let ((compat--generate-function #'compat--generate-testable)
      (load-suffixes '(".el" ".elc"))
      (compat-testing t))
  (load "compat.el"))

(ert-deftest compat-ref-string-search nil "Check if the real `string-search' works as expected."
	     (should
	      (equal 0
		     (string-search "a" "abb")))
	     (should
	      (equal 0
		     (string-search "a" "abba")))
	     (should
	      (equal 0
		     (string-search "aa" "aabbb")))
	     (should
	      (equal 1
		     (string-search "a" "bab")))
	     (should
	      (equal 2
		     (string-search "a" "bba")))
	     (should
	      (equal 1
		     (string-search "aa" "baab")))
	     (should
	      (equal 2
		     (string-search "aa" "bbaa")))
	     (should
	      (equal 2
		     (string-search "a" "AAa")))
	     (1should
	      (equal 2
		     (string-search "aa" "AAaa")))
	     (1should
	      (equal 5
		     (string-search "." "abbbb.b")))
	     (1should
	      (equal 5
		     (string-search ".*" "abbbb.*b")))
	     (1should
	      (equal nil
		     (string-search "a" "bbb")))
	     (1should
	      (equal nil
		     (string-search "." "bbb")))
	     (1should
	      (equal 0
		     (string-search "" "abc")))
	     (1should
	      (equal nil
		     (string-search "a" "")))
	     (1should
	      (equal 0
		     (string-search "" "")))
	     (1should
	      (equal 3
		     (string-search "a" "abba" 1)))
	     (1should
	      (equal 6
		     (string-search "zot" "foobarzot")))
	     (1should
	      (equal 0
		     (string-search "foo" "foobarzot")))
	     (1should
	      (equal nil
		     (string-search "fooz" "foobarzot")))
	     (1should
	      (equal nil
		     (string-search "zot" "foobarzo")))
	     (1should
	      (equal 0
		     (string-search "ab" "ab")))
	     (1should
	      (equal nil
		     (string-search "ab " "ab")))
	     (1should
	      (equal 4
		     (string-search "ab" "abababab" 3)))
	     (1should
	      (equal nil
		     (string-search "ab" "ababac" 3)))
	     (1should
	      (equal nil
		     (string-search "aaa" "aa")))
	     (1should
	      (equal 5
		     (string-search
		      (make-string 2 130)
		      "hellóbár")))
	     (1should
	      (equal 5
		     (string-search
		      (make-string 2 127)
		      "hellóbár")))
	     (1should
	      (equal 1
		     (string-search "\377" "a\377ø")))
	     (1should
	      (equal 1
		     (string-search "\377" "a\377a")))
	     (1should
	      (equal nil
		     (string-search
		      (make-string 1 255)
		      "a\377ø")))
	     (1should
	      (equal nil
		     (string-search
		      (make-string 1 255)
		      "a\377a")))
	     (1should
	      (equal 3
		     (string-search "fóo" "zotfóo")))
	     (1should
	      (equal nil
		     (string-search "\303" "aøb")))
	     (1should
	      (equal nil
		     (string-search "\270" "aøb")))
	     (1should
	      (equal nil
		     (string-search "ø" "\303\270")))
	     (1should
	      (equal nil
		     (string-search "ø"
				    (make-string 32 97))))
	     (1should
	      (equal nil
		     (string-search "ø"
				    (string-to-multibyte
				     (make-string 32 97)))))
	     (1should
	      (equal 14
		     (string-search "o"
				    (string-to-multibyte
				     (apply #'string
					    (number-sequence 97 122))))))
	     (1should
	      (equal 2
		     (string-search "a𐾘z" "a𐾘a𐾘z")))
	     (expect
	      (args-out-of-range -1)
	      "a" "abc" -1)
	     (expect
	      (args-out-of-range 4)
	      "a" "abc" 4)
	     (expect
	      (args-out-of-range 100000000000)
	      "a" "abc" 100000000000)
	     (1should
	      (equal nil
		     (string-search "a" "aaa" 3)))
	     (1should
	      (equal nil
		     (string-search "aa" "aa" 1)))
	     (1should
	      (equal nil
		     (string-search " " "")))
	     (1should
	      (equal 0
		     (string-search "" "")))
	     (expect
	      (args-out-of-range 1)
	      "" "" 1)
	     (1should
	      (equal 0
		     (string-search "" "abc")))
	     (1should
	      (equal 2
		     (string-search "" "abc" 2)))
	     (1should
	      (equal 3
		     (string-search "" "abc" 3)))
	     (expect
	      (args-out-of-range 4)
	      "" "abc" 4)
	     (expect
	      (args-out-of-range -1)
	      "" "abc" -1)
	     (1should
	      (equal nil
		     (string-search "ø" "foo\303\270")))
	     (1should
	      (equal nil
		     (string-search "\303\270" "ø")))
	     (1should
	      (equal nil
		     (string-search "\370" "ø")))
	     (1should
	      (equal nil
		     (string-search
		      (string-to-multibyte "\370")
		      "ø")))
	     (1should
	      (equal nil
		     (string-search "ø" "\370")))
	     (1should
	      (equal nil
		     (string-search "ø"
				    (string-to-multibyte "\370"))))
	     (1should
	      (equal nil
		     (string-search "\303\270" "\370")))
	     (1should
	      (equal nil
		     (string-search
		      (string-to-multibyte "\303\270")
		      "\370")))
	     (1should
	      (equal nil
		     (string-search "\303\270"
				    (string-to-multibyte "\370"))))
	     (1should
	      (equal nil
		     (string-search
		      (string-to-multibyte "\303\270")
		      (string-to-multibyte "\370"))))
	     (1should
	      (equal nil
		     (string-search "\370" "\303\270")))
	     (1should
	      (equal nil
		     (string-search
		      (string-to-multibyte "\370")
		      "\303\270")))
	     (1should
	      (equal nil
		     (string-search "\370"
				    (string-to-multibyte "\303\270"))))
	     (1should
	      (equal nil
		     (string-search
		      (string-to-multibyte "\370")
		      (string-to-multibyte "\303\270"))))
	     (1should
	      (equal 3
		     (string-search "\303\270" "foo\303\270")))
	     (if
		 (version<= "27" emacs-version)
		 (progn
		   (1should
		    (equal 2
			   (string-search
			    (string-to-multibyte "\377")
			    "ab\377c")))
		   (1should
		    (equal 2
			   (string-search
			    (string-to-multibyte "o\303\270")
			    "foo\303\270"))))))
(ert-deftest compat-impl-string-search nil "Check if compat `string-search' works as expected."
	     (1should
	      (equal 0
		     (compat--string-search "a" "abb")))
	     (1should
	      (equal 0
		     (compat--string-search "a" "abba")))
	     (1should
	      (equal 0
		     (compat--string-search "aa" "aabbb")))
	     (1should
	      (equal 1
		     (compat--string-search "a" "bab")))
	     (1should
	      (equal 2
		     (compat--string-search "a" "bba")))
	     (1should
	      (equal 1
		     (compat--string-search "aa" "baab")))
	     (1should
	      (equal 2
		     (compat--string-search "aa" "bbaa")))
	     (1should
	      (equal 2
		     (compat--string-search "a" "AAa")))
	     (1should
	      (equal 2
		     (compat--string-search "aa" "AAaa")))
	     (1should
	      (equal 5
		     (compat--string-search "." "abbbb.b")))
	     (1should
	      (equal 5
		     (compat--string-search ".*" "abbbb.*b")))
	     (1should
	      (equal nil
		     (compat--string-search "a" "bbb")))
	     (1should
	      (equal nil
		     (compat--string-search "." "bbb")))
	     (1should
	      (equal 0
		     (compat--string-search "" "abc")))
	     (1should
	      (equal nil
		     (compat--string-search "a" "")))
	     (1should
	      (equal 0
		     (compat--string-search "" "")))
	     (1should
	      (equal 3
		     (compat--string-search "a" "abba" 1)))
	     (1should
	      (equal 6
		     (compat--string-search "zot" "foobarzot")))
	     (1should
	      (equal 0
		     (compat--string-search "foo" "foobarzot")))
	     (1should
	      (equal nil
		     (compat--string-search "fooz" "foobarzot")))
	     (1should
	      (equal nil
		     (compat--string-search "zot" "foobarzo")))
	     (1should
	      (equal 0
		     (compat--string-search "ab" "ab")))
	     (1should
	      (equal nil
		     (compat--string-search "ab " "ab")))
	     (1should
	      (equal 4
		     (compat--string-search "ab" "abababab" 3)))
	     (1should
	      (equal nil
		     (compat--string-search "ab" "ababac" 3)))
	     (1should
	      (equal nil
		     (compat--string-search "aaa" "aa")))
	     (1should
	      (equal 5
		     (compat--string-search
		      (make-string 2 130)
		      "hellóbár")))
	     (1should
	      (equal 5
		     (compat--string-search
		      (make-string 2 127)
		      "hellóbár")))
	     (1should
	      (equal 1
		     (compat--string-search "\377" "a\377ø")))
	     (1should
	      (equal 1
		     (compat--string-search "\377" "a\377a")))
	     (1should
	      (equal nil
		     (compat--string-search
		      (make-string 1 255)
		      "a\377ø")))
	     (1should
	      (equal nil
		     (compat--string-search
		      (make-string 1 255)
		      "a\377a")))
	     (1should
	      (equal 3
		     (compat--string-search "fóo" "zotfóo")))
	     (1should
	      (equal nil
		     (compat--string-search "\303" "aøb")))
	     (1should
	      (equal nil
		     (compat--string-search "\270" "aøb")))
	     (1should
	      (equal nil
		     (compat--string-search "ø" "\303\270")))
	     (1should
	      (equal nil
		     (compat--string-search "ø"
					    (make-string 32 97))))
	     (1should
	      (equal nil
		     (compat--string-search "ø"
					    (string-to-multibyte
					     (make-string 32 97)))))
	     (1should
	      (equal 14
		     (compat--string-search "o"
					    (string-to-multibyte
					     (apply #'string
						    (number-sequence 97 122))))))
	     (1should
	      (equal 2
		     (compat--string-search "a𐾘z" "a𐾘a𐾘z")))
	     (expect
	      (args-out-of-range -1)
	      "a" "abc" -1)
	     (expect
	      (args-out-of-range 4)
	      "a" "abc" 4)
	     (expect
	      (args-out-of-range 100000000000)
	      "a" "abc" 100000000000)
	     (1should
	      (equal nil
		     (compat--string-search "a" "aaa" 3)))
	     (1should
	      (equal nil
		     (compat--string-search "aa" "aa" 1)))
	     (1should
	      (equal nil
		     (compat--string-search " " "")))
	     (1should
	      (equal 0
		     (compat--string-search "" "")))
	     (expect
	      (args-out-of-range 1)
	      "" "" 1)
	     (1should
	      (equal 0
		     (compat--string-search "" "abc")))
	     (1should
	      (equal 2
		     (compat--string-search "" "abc" 2)))
	     (1should
	      (equal 3
		     (compat--string-search "" "abc" 3)))
	     (expect
	      (args-out-of-range 4)
	      "" "abc" 4)
	     (expect
	      (args-out-of-range -1)
	      "" "abc" -1)
	     (1should
	      (equal nil
		     (compat--string-search "ø" "foo\303\270")))
	     (1should
	      (equal nil
		     (compat--string-search "\303\270" "ø")))
	     (1should
	      (equal nil
		     (compat--string-search "\370" "ø")))
	     (1should
	      (equal nil
		     (compat--string-search
		      (string-to-multibyte "\370")
		      "ø")))
	     (1should
	      (equal nil
		     (compat--string-search "ø" "\370")))
	     (1should
	      (equal nil
		     (compat--string-search "ø"
					    (string-to-multibyte "\370"))))
	     (1should
	      (equal nil
		     (compat--string-search "\303\270" "\370")))
	     (1should
	      (equal nil
		     (compat--string-search
		      (string-to-multibyte "\303\270")
		      "\370")))
	     (1should
	      (equal nil
		     (compat--string-search "\303\270"
					    (string-to-multibyte "\370"))))
	     (1should
	      (equal nil
		     (compat--string-search
		      (string-to-multibyte "\303\270")
		      (string-to-multibyte "\370"))))
	     (1should
	      (equal nil
		     (compat--string-search "\370" "\303\270")))
	     (1should
	      (equal nil
		     (compat--string-search
		      (string-to-multibyte "\370")
		      "\303\270")))
	     (1should
	      (equal nil
		     (compat--string-search "\370"
					    (string-to-multibyte "\303\270"))))
	     (1should
	      (equal nil
		     (compat--string-search
		      (string-to-multibyte "\370")
		      (string-to-multibyte "\303\270"))))
	     (1should
	      (equal 3
		     (compat--string-search "\303\270" "foo\303\270")))
	     (if
		 (version<= "27" emacs-version)
		 (progn
		   (1should
		    (equal 2
			   (compat--string-search
			    (string-to-multibyte "\377")
			    "ab\377c")))
		   (1should
		    (equal 2
			   (compat--string-search
			    (string-to-multibyte "o\303\270")
			    "foo\303\270"))))))
(ert-deftest compat-ref-string-replace nil "Check if the real `string-replace' works as expected."
	     (1should
	      (equal "bba"
		     (string-replace "aa" "bb" "aaa")))
	     (1should
	      (equal "AAA"
		     (string-replace "aa" "bb" "AAA")))
	     (1should
	      (equal "zot"
		     (string-replace "foo" "bar" "zot")))
	     (1should
	      (equal "barzot"
		     (string-replace "foo" "bar" "foozot")))
	     (1should
	      (equal "barbarzot"
		     (string-replace "foo" "bar" "barfoozot")))
	     (1should
	      (equal "barfoobar"
		     (string-replace "zot" "bar" "barfoozot")))
	     (1should
	      (equal "barfoobarot"
		     (string-replace "z" "bar" "barfoozot")))
	     (1should
	      (equal "zat"
		     (string-replace "zot" "bar" "zat")))
	     (1should
	      (equal "zat"
		     (string-replace "azot" "bar" "zat")))
	     (1should
	      (equal "bar"
		     (string-replace "azot" "bar" "azot")))
	     (1should
	      (equal "foozotbar"
		     (string-replace "azot" "bar" "foozotbar")))
	     (1should
	      (equal "labarbarbarzot"
		     (string-replace "fo" "bar" "lafofofozot")))
	     (1should
	      (equal "axb"
		     (string-replace "\377" "x" "a\377b")))
	     (1should
	      (equal "axø"
		     (string-replace "\377" "x" "a\377ø")))
	     (if
		 (version<= "27" emacs-version)
		 (progn
		   (1should
		    (equal "axb"
			   (string-replace
			    (string-to-multibyte "\377")
			    "x" "a\377b")))
		   (1should
		    (equal "axø"
			   (string-replace
			    (string-to-multibyte "\377")
			    "x" "a\377ø")))))
	     (1should
	      (equal "ANAnas"
		     (string-replace "ana" "ANA" "ananas")))
	     (1should
	      (equal ""
		     (string-replace "a" "" "")))
	     (1should
	      (equal ""
		     (string-replace "a" "" "aaaaa")))
	     (1should
	      (equal ""
		     (string-replace "ab" "" "ababab")))
	     (1should
	      (equal "ccc"
		     (string-replace "ab" "" "abcabcabc")))
	     (1should
	      (equal "aaaaaa"
		     (string-replace "a" "aa" "aaa")))
	     (1should
	      (equal "defg"
		     (string-replace "abc" "defg" "abc")))
	     (if
		 (version<= "24.4" emacs-version)
		 (progn
		   (expect wrong-length-argument "" "x" "abc"))))
(ert-deftest compat-impl-string-replace nil "Check if compat `string-replace' works as expected."
	     (1should
	      (equal "bba"
		     (compat--string-replace "aa" "bb" "aaa")))
	     (1should
	      (equal "AAA"
		     (compat--string-replace "aa" "bb" "AAA")))
	     (1should
	      (equal "zot"
		     (compat--string-replace "foo" "bar" "zot")))
	     (1should
	      (equal "barzot"
		     (compat--string-replace "foo" "bar" "foozot")))
	     (1should
	      (equal "barbarzot"
		     (compat--string-replace "foo" "bar" "barfoozot")))
	     (1should
	      (equal "barfoobar"
		     (compat--string-replace "zot" "bar" "barfoozot")))
	     (1should
	      (equal "barfoobarot"
		     (compat--string-replace "z" "bar" "barfoozot")))
	     (1should
	      (equal "zat"
		     (compat--string-replace "zot" "bar" "zat")))
	     (1should
	      (equal "zat"
		     (compat--string-replace "azot" "bar" "zat")))
	     (1should
	      (equal "bar"
		     (compat--string-replace "azot" "bar" "azot")))
	     (1should
	      (equal "foozotbar"
		     (compat--string-replace "azot" "bar" "foozotbar")))
	     (1should
	      (equal "labarbarbarzot"
		     (compat--string-replace "fo" "bar" "lafofofozot")))
	     (1should
	      (equal "axb"
		     (compat--string-replace "\377" "x" "a\377b")))
	     (1should
	      (equal "axø"
		     (compat--string-replace "\377" "x" "a\377ø")))
	     (if
		 (version<= "27" emacs-version)
		 (progn
		   (1should
		    (equal "axb"
			   (compat--string-replace
			    (string-to-multibyte "\377")
			    "x" "a\377b")))
		   (1should
		    (equal "axø"
			   (compat--string-replace
			    (string-to-multibyte "\377")
			    "x" "a\377ø")))))
	     (1should
	      (equal "ANAnas"
		     (compat--string-replace "ana" "ANA" "ananas")))
	     (1should
	      (equal ""
		     (compat--string-replace "a" "" "")))
	     (1should
	      (equal ""
		     (compat--string-replace "a" "" "aaaaa")))
	     (1should
	      (equal ""
		     (compat--string-replace "ab" "" "ababab")))
	     (1should
	      (equal "ccc"
		     (compat--string-replace "ab" "" "abcabcabc")))
	     (1should
	      (equal "aaaaaa"
		     (compat--string-replace "a" "aa" "aaa")))
	     (1should
	      (equal "defg"
		     (compat--string-replace "abc" "defg" "abc")))
	     (if
		 (version<= "24.4" emacs-version)
		 (progn
		   (expect wrong-length-argument "" "x" "abc"))))
(ert-deftest compat-ref-length= nil "Check if the real `length=' works as expected."
	     (1should
	      (equal t
		     (length= 'nil 0)))
	     (1should
	      (equal t
		     (length=
		      '(1)
		      1)))
	     (1should
	      (equal t
		     (length=
		      '(1 2 3)
		      3)))
	     (1should
	      (equal nil
		     (length=
		      '(1 2 3)
		      2)))
	     (1should
	      (equal nil
		     (length=
		      '(1)
		      0)))
	     (1should
	      (equal nil
		     (length=
		      '(1 2 3)
		      4)))
	     (1should
	      (equal nil
		     (length=
		      '(1)
		      2)))
	     (1should
	      (equal nil
		     (length= 'nil 1)))
	     (1should
	      (equal t
		     (length=
		      []
		      0)))
	     (1should
	      (equal t
		     (length=
		      [1]
		      1)))
	     (1should
	      (equal t
		     (length=
		      [1 2 3]
		      3)))
	     (1should
	      (equal nil
		     (length=
		      [1 2 3]
		      2)))
	     (1should
	      (equal nil
		     (length=
		      [1 2 3]
		      4)))
	     (expect wrong-type-argument 3 nil))
(ert-deftest compat-impl-length= nil "Check if compat `length=' works as expected."
	     (1should
	      (equal t
		     (compat--length= 'nil 0)))
	     (1should
	      (equal t
		     (compat--length=
		      '(1)
		      1)))
	     (1should
	      (equal t
		     (compat--length=
		      '(1 2 3)
		      3)))
	     (1should
	      (equal nil
		     (compat--length=
		      '(1 2 3)
		      2)))
	     (1should
	      (equal nil
		     (compat--length=
		      '(1)
		      0)))
	     (1should
	      (equal nil
		     (compat--length=
		      '(1 2 3)
		      4)))
	     (1should
	      (equal nil
		     (compat--length=
		      '(1)
		      2)))
	     (1should
	      (equal nil
		     (compat--length= 'nil 1)))
	     (1should
	      (equal t
		     (compat--length=
		      []
		      0)))
	     (1should
	      (equal t
		     (compat--length=
		      [1]
		      1)))
	     (1should
	      (equal t
		     (compat--length=
		      [1 2 3]
		      3)))
	     (1should
	      (equal nil
		     (compat--length=
		      [1 2 3]
		      2)))
	     (1should
	      (equal nil
		     (compat--length=
		      [1 2 3]
		      4)))
	     (expect wrong-type-argument 3 nil))
(ert-deftest compat-ref-length< nil "Check if the real `length<' works as expected."
	     (1should
	      (equal nil
		     (length<
		      '(1)
		      0)))
	     (1should
	      (equal nil
		     (length<
		      '(1 2 3)
		      2)))
	     (1should
	      (equal nil
		     (length<
		      '(1 2 3)
		      3)))
	     (1should
	      (equal nil
		     (length<
		      '(1)
		      1)))
	     (1should
	      (equal t
		     (length<
		      '(1 2 3)
		      4)))
	     (1should
	      (equal t
		     (length<
		      '(1)
		      2)))
	     (1should
	      (equal t
		     (length< 'nil 1)))
	     (1should
	      (equal nil
		     (length<
		      [1]
		      0)))
	     (1should
	      (equal nil
		     (length<
		      [1 2 3]
		      2)))
	     (1should
	      (equal nil
		     (length<
		      [1 2 3]
		      3)))
	     (1should
	      (equal t
		     (length<
		      [1 2 3]
		      4)))
	     (expect wrong-type-argument 3 nil))
(ert-deftest compat-impl-length< nil "Check if compat `length<' works as expected."
	     (1should
	      (equal nil
		     (compat--length<
		      '(1)
		      0)))
	     (1should
	      (equal nil
		     (compat--length<
		      '(1 2 3)
		      2)))
	     (1should
	      (equal nil
		     (compat--length<
		      '(1 2 3)
		      3)))
	     (1should
	      (equal nil
		     (compat--length<
		      '(1)
		      1)))
	     (1should
	      (equal t
		     (compat--length<
		      '(1 2 3)
		      4)))
	     (1should
	      (equal t
		     (compat--length<
		      '(1)
		      2)))
	     (1should
	      (equal t
		     (compat--length< 'nil 1)))
	     (1should
	      (equal nil
		     (compat--length<
		      [1]
		      0)))
	     (1should
	      (equal nil
		     (compat--length<
		      [1 2 3]
		      2)))
	     (1should
	      (equal nil
		     (compat--length<
		      [1 2 3]
		      3)))
	     (1should
	      (equal t
		     (compat--length<
		      [1 2 3]
		      4)))
	     (expect wrong-type-argument 3 nil))
(ert-deftest compat-ref-length> nil "Check if the real `length>' works as expected."
	     (1should
	      (equal t
		     (length>
		      '(1)
		      0)))
	     (1should
	      (equal t
		     (length>
		      '(1 2 3)
		      2)))
	     (1should
	      (equal nil
		     (length>
		      '(1 2 3)
		      3)))
	     (1should
	      (equal nil
		     (length>
		      '(1)
		      1)))
	     (1should
	      (equal nil
		     (length>
		      '(1 2 3)
		      4)))
	     (1should
	      (equal nil
		     (length>
		      '(1)
		      2)))
	     (1should
	      (equal nil
		     (length> 'nil 1)))
	     (1should
	      (equal t
		     (length>
		      [1]
		      0)))
	     (1should
	      (equal t
		     (length>
		      [1 2 3]
		      2)))
	     (1should
	      (equal nil
		     (length>
		      [1 2 3]
		      3)))
	     (1should
	      (equal nil
		     (length>
		      [1 2 3]
		      4)))
	     (expect wrong-type-argument 3 nil))
(ert-deftest compat-impl-length> nil "Check if compat `length>' works as expected."
	     (1should
	      (equal t
		     (compat--length>
		      '(1)
		      0)))
	     (1should
	      (equal t
		     (compat--length>
		      '(1 2 3)
		      2)))
	     (1should
	      (equal nil
		     (compat--length>
		      '(1 2 3)
		      3)))
	     (1should
	      (equal nil
		     (compat--length>
		      '(1)
		      1)))
	     (1should
	      (equal nil
		     (compat--length>
		      '(1 2 3)
		      4)))
	     (1should
	      (equal nil
		     (compat--length>
		      '(1)
		      2)))
	     (1should
	      (equal nil
		     (compat--length> 'nil 1)))
	     (1should
	      (equal t
		     (compat--length>
		      [1]
		      0)))
	     (1should
	      (equal t
		     (compat--length>
		      [1 2 3]
		      2)))
	     (1should
	      (equal nil
		     (compat--length>
		      [1 2 3]
		      3)))
	     (1should
	      (equal nil
		     (compat--length>
		      [1 2 3]
		      4)))
	     (expect wrong-type-argument 3 nil))
(ert-deftest compat-ref-always nil "Check if the real `always' works as expected."
	     (1should
	      (equal t
		     (always)))
	     (1should
	      (equal t
		     (always 1)))
	     (1should
	      (equal t
		     (always 1 2 3 4))))
(ert-deftest compat-impl-always nil "Check if compat `always' works as expected."
	     (1should
	      (equal t
		     (compat--always)))
	     (1should
	      (equal t
		     (compat--always 1)))
	     (1should
	      (equal t
		     (compat--always 1 2 3 4))))
              ;multiple arguments

(ert-deftest compat-impl-insert-into-buffer-1 ()
  "Check if `insert-into-buffer' can handle no optional argument."
  (with-temp-buffer
    (let ((other (current-buffer)))
      (insert "abc")
      (with-temp-buffer
	(insert "def")
	(compat--insert-into-buffer other))
      (should (string= (buffer-string) "abcdef")))))

(ert-deftest compat-ref-insert-into-buffer-1 ()
  "Check if `insert-into-buffer' can handle no optional argument."
  (skip-unless (fboundp 'insert-into-buffer))
  (with-temp-buffer
    (let ((other (current-buffer)))
      (insert "abc")
      (with-temp-buffer
        (insert "def")
        (insert-into-buffer other))
      (should (string= (buffer-string) "abcdef")))))

(ert-deftest compat-impl-insert-into-buffer-2 ()
  "Check if `insert-into-buffer' handles one optional argument."
  (with-temp-buffer
    (let ((other (current-buffer)))
      (insert "abc")
      (with-temp-buffer
	(insert "def")
	(compat--insert-into-buffer other 2))
      (should (string= (buffer-string) "abcef")))))

(ert-deftest compat-ref-insert-into-buffer-2 ()
  "Check if `insert-into-buffer' handles one optional argument."
  (skip-unless (fboundp 'insert-into-buffer))
  (with-temp-buffer
    (let ((other (current-buffer)))
      (insert "abc")
      (with-temp-buffer
        (insert "def")
        (insert-into-buffer other 2))
      (should (string= (buffer-string) "abcef")))))

(ert-deftest compat-impl-insert-into-buffer-3 ()
  "Check if `insert-into-buffer' handles two optional arguments."
  (with-temp-buffer
    (let ((other (current-buffer)))
      (insert "abc")
      (with-temp-buffer
	(insert "def")
	(compat--insert-into-buffer other 2 3))
      (should (string= (buffer-string) "abce")))))

(ert-deftest compat-ref-insert-into-buffer-3 ()
  "Check if `insert-into-buffer' handles two optional arguments."
  (skip-unless (fboundp 'insert-into-buffer))
  (with-temp-buffer
    (let ((other (current-buffer)))
      (insert "abc")
      (with-temp-buffer
        (insert "def")
        (insert-into-buffer other 2 3))
      (should (string= (buffer-string) "abce")))))(ert-deftest compat-ref-file-name-with-extension nil "Check if the real `file-name-with-extension' works as expected."
	     (1should
	      (equal "file.ext"
		     (file-name-with-extension "file" "ext")))
	     (1should
	      (equal "file.ext"
		     (file-name-with-extension "file" ".ext")))
	     (1should
	      (equal "file.ext"
		     (file-name-with-extension "file." ".ext")))
	     (1should
	      (equal "file..ext"
		     (file-name-with-extension "file.." ".ext")))
	     (1should
	      (equal "file..ext"
		     (file-name-with-extension "file." "..ext")))
	     (1should
	      (equal "file...ext"
		     (file-name-with-extension "file.." "..ext")))
	     (1should
	      (equal "/abs/file.ext"
		     (file-name-with-extension "/abs/file" "ext")))
	     (1should
	      (equal "/abs/file.ext"
		     (file-name-with-extension "/abs/file" ".ext")))
	     (1should
	      (equal "/abs/file.ext"
		     (file-name-with-extension "/abs/file." ".ext")))
	     (1should
	      (equal "/abs/file..ext"
		     (file-name-with-extension "/abs/file.." ".ext")))
	     (1should
	      (equal "/abs/file..ext"
		     (file-name-with-extension "/abs/file." "..ext")))
	     (1should
	      (equal "/abs/file...ext"
		     (file-name-with-extension "/abs/file.." "..ext")))
	     (expect error "file" "")
	     (expect error "" "ext")
	     (expect error "file" "")
	     (expect error "rel/" "ext")
	     (expect error "/abs/" "ext"))
(ert-deftest compat-impl-file-name-with-extension nil "Check if compat `file-name-with-extension' works as expected."
	     (1should
	      (equal "file.ext"
		     (compat--file-name-with-extension "file" "ext")))
	     (1should
	      (equal "file.ext"
		     (compat--file-name-with-extension "file" ".ext")))
	     (1should
	      (equal "file.ext"
		     (compat--file-name-with-extension "file." ".ext")))
	     (1should
	      (equal "file..ext"
		     (compat--file-name-with-extension "file.." ".ext")))
	     (1should
	      (equal "file..ext"
		     (compat--file-name-with-extension "file." "..ext")))
	     (1should
	      (equal "file...ext"
		     (compat--file-name-with-extension "file.." "..ext")))
	     (1should
	      (equal "/abs/file.ext"
		     (compat--file-name-with-extension "/abs/file" "ext")))
	     (1should
	      (equal "/abs/file.ext"
		     (compat--file-name-with-extension "/abs/file" ".ext")))
	     (1should
	      (equal "/abs/file.ext"
		     (compat--file-name-with-extension "/abs/file." ".ext")))
	     (1should
	      (equal "/abs/file..ext"
		     (compat--file-name-with-extension "/abs/file.." ".ext")))
	     (1should
	      (equal "/abs/file..ext"
		     (compat--file-name-with-extension "/abs/file." "..ext")))
	     (1should
	      (equal "/abs/file...ext"
		     (compat--file-name-with-extension "/abs/file.." "..ext")))
	     (expect error "file" "")
	     (expect error "" "ext")
	     (expect error "file" "")
	     (expect error "rel/" "ext")
	     (expect error "/abs/" "ext"))
(ert-deftest compat-ref-compat-string-width nil "Check if the real `compat-string-width' works as expected."
	     (1should
	      (equal 0
		     (compat-string-width "")))
	     (1should
	      (equal 3
		     (compat-string-width "abc")))
	     (1should
	      (equal 5
		     (compat-string-width "abcあ")))
	     (1should
	      (equal
	       (1+ tab-width)
	       (compat-string-width "a	")))
	     (1should
	      (equal 2
		     (compat-string-width "abc" 1)))
	     (1should
	      (equal 4
		     (compat-string-width "abcあ" 1)))
	     (1should
	      (equal tab-width
		     (compat-string-width "a	" 1)))
	     (1should
	      (equal 2
		     (compat-string-width "abc" 0 2)))
	     (1should
	      (equal 3
		     (compat-string-width "abcあ" 0 3)))
	     (1should
	      (equal 1
		     (compat-string-width "a	" 0 1)))
	     (1should
	      (equal 1
		     (compat-string-width "abc" 1 2)))
	     (1should
	      (equal 2
		     (compat-string-width "abcあ" 3 4)))
	     (1should
	      (equal 0
		     (compat-string-width "a	" 1 1))))
(ert-deftest compat-impl-compat-string-width nil "Check if compat `compat-string-width' works as expected."
	     (1should
	      (equal 0
		     (compat--compat-string-width "")))
	     (1should
	      (equal 3
		     (compat--compat-string-width "abc")))
	     (1should
	      (equal 5
		     (compat--compat-string-width "abcあ")))
	     (1should
	      (equal
	       (1+ tab-width)
	       (compat--compat-string-width "a	")))
	     (1should
	      (equal 2
		     (compat--compat-string-width "abc" 1)))
	     (1should
	      (equal 4
		     (compat--compat-string-width "abcあ" 1)))
	     (1should
	      (equal tab-width
		     (compat--compat-string-width "a	" 1)))
	     (1should
	      (equal 2
		     (compat--compat-string-width "abc" 0 2)))
	     (1should
	      (equal 3
		     (compat--compat-string-width "abcあ" 0 3)))
	     (1should
	      (equal 1
		     (compat--compat-string-width "a	" 0 1)))
	     (1should
	      (equal 1
		     (compat--compat-string-width "abc" 1 2)))
	     (1should
	      (equal 2
		     (compat--compat-string-width "abcあ" 3 4)))
	     (1should
	      (equal 0
		     (compat--compat-string-width "a	" 1 1))))
(ert-deftest compat-ref-ensure-list nil "Check if the real `ensure-list' works as expected."
	     (1should
	      (equal nil
		     (ensure-list nil)))
	     (1should
	      (equal
	       '(1)
	       (ensure-list
		'(1))))
	     (1should
	      (equal
	       '(1 2 3)
	       (ensure-list
		'(1 2 3))))
	     (1should
	      (equal
	       '(1)
	       (ensure-list 1))))
(ert-deftest compat-impl-ensure-list nil "Check if compat `ensure-list' works as expected."
	     (1should
	      (equal nil
		     (compat--ensure-list nil)))
	     (1should
	      (equal
	       '(1)
	       (compat--ensure-list
		'(1))))
	     (1should
	      (equal
	       '(1 2 3)
	       (compat--ensure-list
		'(1 2 3))))
	     (1should
	      (equal
	       '(1)
	       (compat--ensure-list 1))))
(ert-deftest compat-ref-proper-list-p nil "Check if the real `proper-list-p' works as expected."
	     (1should
	      (equal 0
		     (proper-list-p nil)))
	     (1should
	      (equal 1
		     (proper-list-p
		      '(1))))
	     (1should
	      (equal 3
		     (proper-list-p
		      '(1 2 3))))
	     (1should
	      (equal nil
		     (proper-list-p
		      '(1 . 2))))
	     (1should
	      (equal nil
		     (proper-list-p
		      '(1 2 . 3))))
	     (1should
	      (equal nil
		     (proper-list-p
		      (let
			  ((l
			    (list 1 2 3)))
			(if
			    (<= 3 0)
			    (setq l l)
			  (setcdr
			   (nthcdr
			    (1- 3)
			    l)
			   l))
			l))))
	     (1should
	      (equal nil
		     (proper-list-p 1)))
	     (1should
	      (equal nil
		     (proper-list-p "")))
	     (1should
	      (equal nil
		     (proper-list-p "abc")))
	     (1should
	      (equal nil
		     (proper-list-p
		      [])))
	     (1should
	      (equal nil
		     (proper-list-p
		      [1 2 3]))))
(ert-deftest compat-impl-proper-list-p nil "Check if compat `proper-list-p' works as expected."
	     (1should
	      (equal 0
		     (compat--proper-list-p-length-signal nil)))
	     (1should
	      (equal 1
		     (compat--proper-list-p-length-signal
		      '(1))))
	     (1should
	      (equal 3
		     (compat--proper-list-p-length-signal
		      '(1 2 3))))
	     (1should
	      (equal nil
		     (compat--proper-list-p-length-signal
		      '(1 . 2))))
	     (1should
	      (equal nil
		     (compat--proper-list-p-length-signal
		      '(1 2 . 3))))
	     (1should
	      (equal nil
		     (compat--proper-list-p-length-signal
		      (let
			  ((l
			    (list 1 2 3)))
			(if
			    (<= 3 0)
			    (setq l l)
			  (setcdr
			   (nthcdr
			    (1- 3)
			    l)
			   l))
			l))))
	     (1should
	      (equal nil
		     (compat--proper-list-p-length-signal 1)))
	     (1should
	      (equal nil
		     (compat--proper-list-p-length-signal "")))
	     (1should
	      (equal nil
		     (compat--proper-list-p-length-signal "abc")))
	     (1should
	      (equal nil
		     (compat--proper-list-p-length-signal
		      [])))
	     (1should
	      (equal nil
		     (compat--proper-list-p-length-signal
		      [1 2 3]))))
(ert-deftest compat-ref-proper-list-p nil "Check if the real `proper-list-p' works as expected."
	     (1should
	      (equal 0
		     (proper-list-p nil)))
	     (1should
	      (equal 1
		     (proper-list-p
		      '(1))))
	     (1should
	      (equal 3
		     (proper-list-p
		      '(1 2 3))))
	     (1should
	      (equal nil
		     (proper-list-p
		      '(1 . 2))))
	     (1should
	      (equal nil
		     (proper-list-p
		      '(1 2 . 3))))
	     (1should
	      (equal nil
		     (proper-list-p
		      (let
			  ((l
			    (list 1 2 3)))
			(if
			    (<= 3 0)
			    (setq l l)
			  (setcdr
			   (nthcdr
			    (1- 3)
			    l)
			   l))
			l))))
	     (1should
	      (equal nil
		     (proper-list-p 1)))
	     (1should
	      (equal nil
		     (proper-list-p "")))
	     (1should
	      (equal nil
		     (proper-list-p "abc")))
	     (1should
	      (equal nil
		     (proper-list-p
		      [])))
	     (1should
	      (equal nil
		     (proper-list-p
		      [1 2 3]))))
(ert-deftest compat-impl-proper-list-p nil "Check if compat `proper-list-p' works as expected."
	     (1should
	      (equal 0
		     (compat--proper-list-p-tortoise-hare nil)))
	     (1should
	      (equal 1
		     (compat--proper-list-p-tortoise-hare
		      '(1))))
	     (1should
	      (equal 3
		     (compat--proper-list-p-tortoise-hare
		      '(1 2 3))))
	     (1should
	      (equal nil
		     (compat--proper-list-p-tortoise-hare
		      '(1 . 2))))
	     (1should
	      (equal nil
		     (compat--proper-list-p-tortoise-hare
		      '(1 2 . 3))))
	     (1should
	      (equal nil
		     (compat--proper-list-p-tortoise-hare
		      (let
			  ((l
			    (list 1 2 3)))
			(if
			    (<= 3 0)
			    (setq l l)
			  (setcdr
			   (nthcdr
			    (1- 3)
			    l)
			   l))
			l))))
	     (1should
	      (equal nil
		     (compat--proper-list-p-tortoise-hare 1)))
	     (1should
	      (equal nil
		     (compat--proper-list-p-tortoise-hare "")))
	     (1should
	      (equal nil
		     (compat--proper-list-p-tortoise-hare "abc")))
	     (1should
	      (equal nil
		     (compat--proper-list-p-tortoise-hare
		      [])))
	     (1should
	      (equal nil
		     (compat--proper-list-p-tortoise-hare
		      [1 2 3]))))
(ert-deftest compat-ref-flatten-tree nil "Check if the real `flatten-tree' works as expected."
	     (1should
	      (equal
	       '(1 2 3 4 5 6 7)
	       (flatten-tree
		'(1
		  (2 . 3)
		  nil
		  (4 5
		     (6))
		  7))))
	     (1should
	      (equal nil
		     (flatten-tree nil)))
	     (1should
	      (equal
	       '(1)
	       (flatten-tree
		'(1))))
	     (1should
	      (equal
	       '(1 2)
	       (flatten-tree
		'(1 2))))
	     (1should
	      (equal
	       '(1 2 3)
	       (flatten-tree
		'(1 2 3))))
	     (1should
	      (equal
	       '(1)
	       (flatten-tree
		'((1)))))
	     (1should
	      (equal
	       '(1 2)
	       (flatten-tree
		'((1)
		  (2)))))
	     (1should
	      (equal
	       '(1 2 3)
	       (flatten-tree
		'((1)
		  (2)
		  (3)))))
	     (1should
	      (equal
	       '(1)
	       (flatten-tree
		'(((((1))))))))
	     (1should
	      (equal
	       '(1 2 3 4)
	       (flatten-tree
		'((1)
		  nil 2
		  ((3 4))))))
	     (1should
	      (equal
	       '(1 2 3 4)
	       (flatten-tree
		'(((1 nil))
		  2
		  (((3 nil nil)
		    4)))))))
(ert-deftest compat-impl-flatten-tree nil "Check if compat `flatten-tree' works as expected."
	     (1should
	      (equal
	       '(1 2 3 4 5 6 7)
	       (compat--flatten-tree
		'(1
		  (2 . 3)
		  nil
		  (4 5
		     (6))
		  7))))
	     (1should
	      (equal nil
		     (compat--flatten-tree nil)))
	     (1should
	      (equal
	       '(1)
	       (compat--flatten-tree
		'(1))))
	     (1should
	      (equal
	       '(1 2)
	       (compat--flatten-tree
		'(1 2))))
	     (1should
	      (equal
	       '(1 2 3)
	       (compat--flatten-tree
		'(1 2 3))))
	     (1should
	      (equal
	       '(1)
	       (compat--flatten-tree
		'((1)))))
	     (1should
	      (equal
	       '(1 2)
	       (compat--flatten-tree
		'((1)
		  (2)))))
	     (1should
	      (equal
	       '(1 2 3)
	       (compat--flatten-tree
		'((1)
		  (2)
		  (3)))))
	     (1should
	      (equal
	       '(1)
	       (compat--flatten-tree
		'(((((1))))))))
	     (1should
	      (equal
	       '(1 2 3 4)
	       (compat--flatten-tree
		'((1)
		  nil 2
		  ((3 4))))))
	     (1should
	      (equal
	       '(1 2 3 4)
	       (compat--flatten-tree
		'(((1 nil))
		  2
		  (((3 nil nil)
		    4)))))))
(ert-deftest compat-ref-xor nil "Check if the real `xor' works as expected."
	     (1should
	      (equal t
		     (xor t nil)))
	     (1should
	      (equal t
		     (xor nil t)))
	     (1should
	      (equal nil
		     (xor nil nil)))
	     (1should
	      (equal nil
		     (xor t t))))
(ert-deftest compat-impl-xor nil "Check if compat `xor' works as expected."
	     (1should
	      (equal t
		     (compat--xor t nil)))
	     (1should
	      (equal t
		     (compat--xor nil t)))
	     (1should
	      (equal nil
		     (compat--xor nil nil)))
	     (1should
	      (equal nil
		     (compat--xor t t))))
(ert-deftest compat-ref-string-distance nil "Check if the real `string-distance' works as expected."
	     (1should
	      (equal 3
		     (string-distance "kitten" "sitting")))
	     (if
		 (version<= "28" emacs-version)
		 (1should
		  (equal 0
			 (string-distance "" "")))
	       (let*
		   ((fn-1303 #'=)
		    (args-1304
		     (condition-case err
			 (let
			     ((signal-hook-function #'ert--should-signal-hook))
			   (list
			    (compat--string-distance "" "")
			    0))
		       (error
			(progn
			  (setq fn-1303 #'signal)
			  (list
			   (car err)
			   (cdr err)))))))
		 (let
		     ((value-1305 'ert-form-evaluation-aborted-1306))
		   (let
		       (form-description-1307)
		     (if
			 (unwind-protect
			     (setq value-1305
				   (apply fn-1303 args-1304))
			   (setq form-description-1307
				 (nconc
				  (list
				   '(should
				     (=
				      (compat--string-distance "" "")
				      0)))
				  (list :form
					(cons fn-1303 args-1304))
				  (if
				      (eql value-1305 'ert-form-evaluation-aborted-1306)
				      nil
				    (list :value value-1305))
				  (if
				      (eql value-1305 'ert-form-evaluation-aborted-1306)
				      nil
				    (let*
					((-explainer-
					  (and t
					       (ert--get-explainer '=))))
				      (if -explainer-
					  (list :explanation
						(apply -explainer- args-1304))
					nil)))))
			   (ert--signal-should-execution form-description-1307))
			 nil
		       (ert-fail form-description-1307)))
		   value-1305)))
	     (1should
	      (equal 0
		     (string-distance "a" "a")))
	     (1should
	      (equal 1
		     (string-distance "" "a")))
	     (1should
	      (equal 1
		     (string-distance "b" "a")))
	     (1should
	      (equal 2
		     (string-distance "aa" "bb")))
	     (1should
	      (equal 2
		     (string-distance "aa" "bba")))
	     (1should
	      (equal 2
		     (string-distance "aaa" "bba")))
	     (1should
	      (equal 3
		     (string-distance "a" "あ" t)))
	     (1should
	      (equal 1
		     (string-distance "a" "あ"))))
(ert-deftest compat-impl-string-distance nil "Check if compat `string-distance' works as expected."
	     (1should
	      (equal 3
		     (compat--string-distance "kitten" "sitting")))
	     (if
		 (version<= "28" emacs-version)
		 (1should
		  (equal 0
			 (compat--string-distance "" "")))
	       (let*
		   ((fn-1308 #'=)
		    (args-1309
		     (condition-case err
			 (let
			     ((signal-hook-function #'ert--should-signal-hook))
			   (list
			    (compat--string-distance "" "")
			    0))
		       (error
			(progn
			  (setq fn-1308 #'signal)
			  (list
			   (car err)
			   (cdr err)))))))
		 (let
		     ((value-1310 'ert-form-evaluation-aborted-1311))
		   (let
		       (form-description-1312)
		     (if
			 (unwind-protect
			     (setq value-1310
				   (apply fn-1308 args-1309))
			   (setq form-description-1312
				 (nconc
				  (list
				   '(should
				     (=
				      (compat--string-distance "" "")
				      0)))
				  (list :form
					(cons fn-1308 args-1309))
				  (if
				      (eql value-1310 'ert-form-evaluation-aborted-1311)
				      nil
				    (list :value value-1310))
				  (if
				      (eql value-1310 'ert-form-evaluation-aborted-1311)
				      nil
				    (let*
					((-explainer-
					  (and t
					       (ert--get-explainer '=))))
				      (if -explainer-
					  (list :explanation
						(apply -explainer- args-1309))
					nil)))))
			   (ert--signal-should-execution form-description-1312))
			 nil
		       (ert-fail form-description-1312)))
		   value-1310)))
	     (1should
	      (equal 0
		     (compat--string-distance "a" "a")))
	     (1should
	      (equal 1
		     (compat--string-distance "" "a")))
	     (1should
	      (equal 1
		     (compat--string-distance "b" "a")))
	     (1should
	      (equal 2
		     (compat--string-distance "aa" "bb")))
	     (1should
	      (equal 2
		     (compat--string-distance "aa" "bba")))
	     (1should
	      (equal 2
		     (compat--string-distance "aaa" "bba")))
	     (1should
	      (equal 3
		     (compat--string-distance "a" "あ" t)))
	     (1should
	      (equal 1
		     (compat--string-distance "a" "あ"))))


(ert-deftest compat-impl-regexp-unmatchable ()
  "Check if the real `regexp-unmatchable' works as assumed."
  (dolist (str '(""                     ;empty string
                 "a"                    ;simple string
                 "aaa"                  ;longer string
                 ))
    (should-not (string-match-p (with-no-warnings compat--regexp-unmatchable) str))))

(ert-deftest compat-ref-regexp-unmatchable ()
  "Check if the compat `regexp-unmatchable' works as expected."
  (skip-unless (boundp 'regexp-unmatchable))
  (dolist (str '(""                     ;empty string
                 "a"                    ;simple string
                 "aaa"                  ;longer string
                 ))
    (should-not (string-match-p regexp-unmatchable str))))(ert-deftest compat-ref-compat-regexp-opt nil "Check if the real `compat-regexp-opt' works as expected."
	     (1should
	      (equal
	       (regexp-opt
		'("a" "b" "c"))
	       (compat-regexp-opt
		'("a" "b" "c"))))
	     (1should
	      (equal
	       (regexp-opt
		'("abc" "def" "ghe"))
	       (compat-regexp-opt
		'("abc" "def" "ghe"))))
	     (1should
	      (equal
	       (regexp-opt
		'("a" "b" "c")
		'words)
	       (compat-regexp-opt
		'("a" "b" "c")
		'words)))
	     (1should
	      (equal "\\(?:\\`a\\`\\)"
		     (compat-regexp-opt 'nil)))
	     (1should
	      (equal "\\<\\(\\`a\\`\\)\\>"
		     (compat-regexp-opt 'nil 'words))))
(ert-deftest compat-impl-compat-regexp-opt nil "Check if compat `compat-regexp-opt' works as expected."
	     (1should
	      (equal
	       (regexp-opt
		'("a" "b" "c"))
	       (compat--compat-regexp-opt
		'("a" "b" "c"))))
	     (1should
	      (equal
	       (regexp-opt
		'("abc" "def" "ghe"))
	       (compat--compat-regexp-opt
		'("abc" "def" "ghe"))))
	     (1should
	      (equal
	       (regexp-opt
		'("a" "b" "c")
		'words)
	       (compat--compat-regexp-opt
		'("a" "b" "c")
		'words)))
	     (1should
	      (equal "\\(?:\\`a\\`\\)"
		     (compat--compat-regexp-opt 'nil)))
	     (1should
	      (equal "\\<\\(\\`a\\`\\)\\>"
		     (compat--compat-regexp-opt 'nil 'words))))
(ert-deftest compat-ref-compat-assoc nil "Check if the real `compat-assoc' works as expected."
	     (1should
	      (equal nil
		     (compat-assoc 1 nil)))
	     (1should
	      (equal
	       '(1)
	       (compat-assoc 1
			     '((1)))))
	     (1should
	      (equal nil
		     (compat-assoc 1
				   '(1))))
	     (1should
	      (equal
	       '(2)
	       (compat-assoc 2
			     '((1)
			       (2)
			       (3)))))
	     (1should
	      (equal nil
		     (compat-assoc 2
				   '(1 2 3))))
	     (1should
	      (equal
	       '(2)
	       (compat-assoc 2
			     '(1
			       (2)
			       3))))
	     (1should
	      (equal nil
		     (compat-assoc 2
				   '((1)
				     2
				     (3)))))
	     (1should
	      (equal
	       '(1)
	       (compat-assoc 1
			     '((3)
			       (2)
			       (1)))))
	     (1should
	      (equal
	       '("a")
	       (compat-assoc "a"
			     '(("a")
			       ("b")
			       ("c")))))
	     (1should
	      (equal
	       '("a" 0)
	       (compat-assoc "a"
			     '(("c" . "a")
			       "b"
			       ("a" 0)))))
	     (1should
	      (equal
	       '(1)
	       (compat-assoc 3
			     '((10)
			       (4)
			       (1)
			       (9))
			     #'<)))
	     (1should
	      (equal
	       '("a")
	       (compat-assoc "b"
			     '(("c")
			       ("a")
			       ("b"))
			     #'string-lessp)))
	     (1should
	      (equal
	       '("b")
	       (compat-assoc "a"
			     '(("a")
			       ("a")
			       ("b"))
			     #'(lambda
				 (s1 s2)
				 (not
				  (string= s1 s2))))))
	     (1should
	      (equal
	       '("\\.el\\'" . emacs-lisp-mode)
	       (compat-assoc "file.el"
			     '(("\\.c\\'" . c-mode)
			       ("\\.p\\'" . pascal-mode)
			       ("\\.el\\'" . emacs-lisp-mode)
			       ("\\.awk\\'" . awk-mode))
			     #'string-match-p))))
(ert-deftest compat-impl-compat-assoc nil "Check if compat `compat-assoc' works as expected."
	     (1should
	      (equal nil
		     (compat--compat-assoc 1 nil)))
	     (1should
	      (equal
	       '(1)
	       (compat--compat-assoc 1
				     '((1)))))
	     (1should
	      (equal nil
		     (compat--compat-assoc 1
					   '(1))))
	     (1should
	      (equal
	       '(2)
	       (compat--compat-assoc 2
				     '((1)
				       (2)
				       (3)))))
	     (1should
	      (equal nil
		     (compat--compat-assoc 2
					   '(1 2 3))))
	     (1should
	      (equal
	       '(2)
	       (compat--compat-assoc 2
				     '(1
				       (2)
				       3))))
	     (1should
	      (equal nil
		     (compat--compat-assoc 2
					   '((1)
					     2
					     (3)))))
	     (1should
	      (equal
	       '(1)
	       (compat--compat-assoc 1
				     '((3)
				       (2)
				       (1)))))
	     (1should
	      (equal
	       '("a")
	       (compat--compat-assoc "a"
				     '(("a")
				       ("b")
				       ("c")))))
	     (1should
	      (equal
	       '("a" 0)
	       (compat--compat-assoc "a"
				     '(("c" . "a")
				       "b"
				       ("a" 0)))))
	     (1should
	      (equal
	       '(1)
	       (compat--compat-assoc 3
				     '((10)
				       (4)
				       (1)
				       (9))
				     #'<)))
	     (1should
	      (equal
	       '("a")
	       (compat--compat-assoc "b"
				     '(("c")
				       ("a")
				       ("b"))
				     #'string-lessp)))
	     (1should
	      (equal
	       '("b")
	       (compat--compat-assoc "a"
				     '(("a")
				       ("a")
				       ("b"))
				     #'(lambda
					 (s1 s2)
					 (not
					  (string= s1 s2))))))
	     (1should
	      (equal
	       '("\\.el\\'" . emacs-lisp-mode)
	       (compat--compat-assoc "file.el"
				     '(("\\.c\\'" . c-mode)
				       ("\\.p\\'" . pascal-mode)
				       ("\\.el\\'" . emacs-lisp-mode)
				       ("\\.awk\\'" . awk-mode))
				     #'string-match-p))))
(ert-deftest compat-ref-alist-get nil "Check if the real `alist-get' works as expected."
	     (1should
	      (equal nil
		     (alist-get 1 nil)))
	     (1should
	      (equal 'a
		     (alist-get 1
				'((1 . a)))))
	     (1should
	      (equal nil
		     (alist-get 1
				'(1))))
	     (1should
	      (equal 'b
		     (alist-get 2
				'((1 . a)
				  (2 . b)
				  (3 . c)))))
	     (1should
	      (equal nil
		     (alist-get 2
				'(1 2 3))))
	     (1should
	      (equal 'b
		     (alist-get 2
				'(1
				  (2 . b)
				  3))))
	     (1should
	      (equal nil
		     (alist-get 2
				'((1 . a)
				  2
				  (3 . c)))))
	     (1should
	      (equal 'a
		     (alist-get 1
				'((3 . c)
				  (2 . b)
				  (1 . a)))))
	     (1should
	      (equal nil
		     (alist-get "a"
				'(("a" . 1)
				  ("b" . 2)
				  ("c" . 3)))))
	     (1should
	      (equal 1
		     (alist-get "a"
				'(("a" . 1)
				  ("b" . 2)
				  ("c" . 3))
				nil nil #'equal)))
	     (1should
	      (equal 1
		     (alist-get 3
				'((10 . 10)
				  (4 . 4)
				  (1 . 1)
				  (9 . 9))
				nil nil #'<)))
	     (1should
	      (equal
	       '(a)
	       (alist-get "b"
			  '(("c" c)
			    ("a" a)
			    ("b" b))
			  nil nil #'string-lessp)))
	     (1should
	      (equal 'c
		     (alist-get "a"
				'(("a" . a)
				  ("a" . b)
				  ("b" . c))
				nil nil
				#'(lambda
				    (s1 s2)
				    (not
				     (string= s1 s2))))))
	     (1should
	      (equal 'emacs-lisp-mode
		     (alist-get "file.el"
				'(("\\.c\\'" . c-mode)
				  ("\\.p\\'" . pascal-mode)
				  ("\\.el\\'" . emacs-lisp-mode)
				  ("\\.awk\\'" . awk-mode))
				nil nil #'string-match-p)))
	     (1should
	      (equal 'd
		     (alist-get 0
				'((1 . a)
				  (2 . b)
				  (3 . c))
				'd)))
	     (1should
	      (equal 'd
		     (alist-get 2
				'((1 . a)
				  (2 . b)
				  (3 . c))
				'd nil #'ignore))))
(ert-deftest compat-impl-alist-get nil "Check if compat `alist-get' works as expected."
	     (1should
	      (equal nil
		     (compat--alist-get-full-elisp 1 nil)))
	     (1should
	      (equal 'a
		     (compat--alist-get-full-elisp 1
						   '((1 . a)))))
	     (1should
	      (equal nil
		     (compat--alist-get-full-elisp 1
						   '(1))))
	     (1should
	      (equal 'b
		     (compat--alist-get-full-elisp 2
						   '((1 . a)
						     (2 . b)
						     (3 . c)))))
	     (1should
	      (equal nil
		     (compat--alist-get-full-elisp 2
						   '(1 2 3))))
	     (1should
	      (equal 'b
		     (compat--alist-get-full-elisp 2
						   '(1
						     (2 . b)
						     3))))
	     (1should
	      (equal nil
		     (compat--alist-get-full-elisp 2
						   '((1 . a)
						     2
						     (3 . c)))))
	     (1should
	      (equal 'a
		     (compat--alist-get-full-elisp 1
						   '((3 . c)
						     (2 . b)
						     (1 . a)))))
	     (1should
	      (equal nil
		     (compat--alist-get-full-elisp "a"
						   '(("a" . 1)
						     ("b" . 2)
						     ("c" . 3)))))
	     (1should
	      (equal 1
		     (compat--alist-get-full-elisp "a"
						   '(("a" . 1)
						     ("b" . 2)
						     ("c" . 3))
						   nil nil #'equal)))
	     (1should
	      (equal 1
		     (compat--alist-get-full-elisp 3
						   '((10 . 10)
						     (4 . 4)
						     (1 . 1)
						     (9 . 9))
						   nil nil #'<)))
	     (1should
	      (equal
	       '(a)
	       (compat--alist-get-full-elisp "b"
					     '(("c" c)
					       ("a" a)
					       ("b" b))
					     nil nil #'string-lessp)))
	     (1should
	      (equal 'c
		     (compat--alist-get-full-elisp "a"
						   '(("a" . a)
						     ("a" . b)
						     ("b" . c))
						   nil nil
						   #'(lambda
						       (s1 s2)
						       (not
							(string= s1 s2))))))
	     (1should
	      (equal 'emacs-lisp-mode
		     (compat--alist-get-full-elisp "file.el"
						   '(("\\.c\\'" . c-mode)
						     ("\\.p\\'" . pascal-mode)
						     ("\\.el\\'" . emacs-lisp-mode)
						     ("\\.awk\\'" . awk-mode))
						   nil nil #'string-match-p)))
	     (1should
	      (equal 'd
		     (compat--alist-get-full-elisp 0
						   '((1 . a)
						     (2 . b)
						     (3 . c))
						   'd)))
	     (1should
	      (equal 'd
		     (compat--alist-get-full-elisp 2
						   '((1 . a)
						     (2 . b)
						     (3 . c))
						   'd nil #'ignore))))


(ert-deftest compat-ref-alist-get-gv ()
  "Check if the real `alist-get' works as a generalised variable."
  (skip-unless (get 'alist-get 'gv-expander))
  (let ((alist-1 (list (cons 1 "one")
                       (cons 2 "two")
                       (cons 3 "three")))
        (alist-2 (list (cons "one" 1)
                       (cons "two" 2)
                       (cons "three" 3))))
    (setf (alist-get 1 alist-1) "eins")
    (should (equal (alist-get 1 alist-1) "eins"))
    (setf (alist-get 2 alist-1 nil 'remove) nil)
    (should (equal alist-1 '((1 . "eins") (3 . "three"))))
    (setf (alist-get "one" alist-2 nil nil #'string=) "eins")
    (should (equal (alist-get "one" alist-2 nil nil #'string=)
                   "eins"))))

(ert-deftest compat-alist-get-gv ()
  "Check if the compat `alist-get' works as a generalised variable."
  (let ((alist-1 (list (cons 1 "one")
                       (cons 2 "two")
                       (cons 3 "three")))
        (alist-2 (list (cons "one" 1)
                       (cons "two" 2)
                       (cons "three" 3))))
    (setf (compat-alist-get 1 alist-1) "eins")
    (should (equal (compat-alist-get 1 alist-1) "eins"))
    (setf (compat-alist-get 2 alist-1 nil 'remove) nil)
    (should (equal alist-1 '((1 . "eins") (3 . "three"))))
    (setf (compat-alist-get "one" alist-2 nil nil #'string=) "eins")
    (should (equal (compat-alist-get "one" alist-2 nil nil #'string=)
                   "eins"))))(ert-deftest compat-ref-string-trim-left nil "Check if the real `string-trim-left' works as expected."
	     (1should
	      (equal ""
		     (string-trim-left "")))
	     (1should
	      (equal "a"
		     (string-trim-left "a")))
	     (1should
	      (equal "aaa"
		     (string-trim-left "aaa")))
	     (1should
	      (equal "へっろ"
		     (string-trim-left "へっろ")))
	     (1should
	      (equal "hello world"
		     (string-trim-left "hello world")))
	     (1should
	      (equal "a "
		     (string-trim-left "a ")))
	     (1should
	      (equal "aaa "
		     (string-trim-left "aaa ")))
	     (1should
	      (equal "a    "
		     (string-trim-left "a    ")))
	     (1should
	      (equal "a		"
		     (string-trim-left "a		")))
	     (1should
	      (equal "a\n  	"
		     (string-trim-left "a\n  	")))
	     (1should
	      (equal "a"
		     (string-trim-left " a")))
	     (1should
	      (equal "aaa"
		     (string-trim-left " aaa")))
	     (1should
	      (equal "a"
		     (string-trim-left "a")))
	     (1should
	      (equal "a"
		     (string-trim-left "		a")))
	     (1should
	      (equal "a"
		     (string-trim-left "\n  	a")))
	     (1should
	      (equal "a "
		     (string-trim-left " a ")))
	     (1should
	      (equal "aaa  "
		     (string-trim-left " aaa  ")))
	     (1should
	      (equal "a	\n"
		     (string-trim-left "		a	\n")))
	     (1should
	      (equal "a  \n"
		     (string-trim-left "\n  	a  \n"))))
(ert-deftest compat-impl-string-trim-left nil "Check if compat `string-trim-left' works as expected."
	     (1should
	      (equal ""
		     (compat--string-trim-left "")))
	     (1should
	      (equal "a"
		     (compat--string-trim-left "a")))
	     (1should
	      (equal "aaa"
		     (compat--string-trim-left "aaa")))
	     (1should
	      (equal "へっろ"
		     (compat--string-trim-left "へっろ")))
	     (1should
	      (equal "hello world"
		     (compat--string-trim-left "hello world")))
	     (1should
	      (equal "a "
		     (compat--string-trim-left "a ")))
	     (1should
	      (equal "aaa "
		     (compat--string-trim-left "aaa ")))
	     (1should
	      (equal "a    "
		     (compat--string-trim-left "a    ")))
	     (1should
	      (equal "a		"
		     (compat--string-trim-left "a		")))
	     (1should
	      (equal "a\n  	"
		     (compat--string-trim-left "a\n  	")))
	     (1should
	      (equal "a"
		     (compat--string-trim-left " a")))
	     (1should
	      (equal "aaa"
		     (compat--string-trim-left " aaa")))
	     (1should
	      (equal "a"
		     (compat--string-trim-left "a")))
	     (1should
	      (equal "a"
		     (compat--string-trim-left "		a")))
	     (1should
	      (equal "a"
		     (compat--string-trim-left "\n  	a")))
	     (1should
	      (equal "a "
		     (compat--string-trim-left " a ")))
	     (1should
	      (equal "aaa  "
		     (compat--string-trim-left " aaa  ")))
	     (1should
	      (equal "a	\n"
		     (compat--string-trim-left "		a	\n")))
	     (1should
	      (equal "a  \n"
		     (compat--string-trim-left "\n  	a  \n"))))
(ert-deftest compat-ref-string-trim-right nil "Check if the real `string-trim-right' works as expected."
	     (1should
	      (equal ""
		     (string-trim-right "")))
	     (1should
	      (equal "a"
		     (string-trim-right "a")))
	     (1should
	      (equal "aaa"
		     (string-trim-right "aaa")))
	     (1should
	      (equal "へっろ"
		     (string-trim-right "へっろ")))
	     (1should
	      (equal "hello world"
		     (string-trim-right "hello world")))
	     (1should
	      (equal "a"
		     (string-trim-right "a")))
	     (1should
	      (equal "aaa"
		     (string-trim-right "aaa")))
	     (1should
	      (equal "a"
		     (string-trim-right "a    ")))
	     (1should
	      (equal "a"
		     (string-trim-right "a		")))
	     (1should
	      (equal "a"
		     (string-trim-right "a\n  	")))
	     (1should
	      (equal " a"
		     (string-trim-right " a")))
	     (1should
	      (equal " aaa"
		     (string-trim-right " aaa")))
	     (1should
	      (equal "a"
		     (string-trim-right "a")))
	     (1should
	      (equal "		a"
		     (string-trim-right "		a")))
	     (1should
	      (equal "\n  	a"
		     (string-trim-right "\n  	a")))
	     (1should
	      (equal " a"
		     (string-trim-right " a ")))
	     (1should
	      (equal " aaa"
		     (string-trim-right " aaa")))
	     (1should
	      (equal "		a"
		     (string-trim-right "		a	\n")))
	     (1should
	      (equal "\n  	a"
		     (string-trim-right "\n  	a  \n"))))
(ert-deftest compat-impl-string-trim-right nil "Check if compat `string-trim-right' works as expected."
	     (1should
	      (equal ""
		     (compat--string-trim-right "")))
	     (1should
	      (equal "a"
		     (compat--string-trim-right "a")))
	     (1should
	      (equal "aaa"
		     (compat--string-trim-right "aaa")))
	     (1should
	      (equal "へっろ"
		     (compat--string-trim-right "へっろ")))
	     (1should
	      (equal "hello world"
		     (compat--string-trim-right "hello world")))
	     (1should
	      (equal "a"
		     (compat--string-trim-right "a")))
	     (1should
	      (equal "aaa"
		     (compat--string-trim-right "aaa")))
	     (1should
	      (equal "a"
		     (compat--string-trim-right "a    ")))
	     (1should
	      (equal "a"
		     (compat--string-trim-right "a		")))
	     (1should
	      (equal "a"
		     (compat--string-trim-right "a\n  	")))
	     (1should
	      (equal " a"
		     (compat--string-trim-right " a")))
	     (1should
	      (equal " aaa"
		     (compat--string-trim-right " aaa")))
	     (1should
	      (equal "a"
		     (compat--string-trim-right "a")))
	     (1should
	      (equal "		a"
		     (compat--string-trim-right "		a")))
	     (1should
	      (equal "\n  	a"
		     (compat--string-trim-right "\n  	a")))
	     (1should
	      (equal " a"
		     (compat--string-trim-right " a ")))
	     (1should
	      (equal " aaa"
		     (compat--string-trim-right " aaa")))
	     (1should
	      (equal "		a"
		     (compat--string-trim-right "		a	\n")))
	     (1should
	      (equal "\n  	a"
		     (compat--string-trim-right "\n  	a  \n"))))
(ert-deftest compat-ref-compat-string-trim nil "Check if the real `compat-string-trim' works as expected."
	     (1should
	      (equal ""
		     (compat-string-trim "")))
	     (1should
	      (equal "a"
		     (compat-string-trim "a")))
	     (1should
	      (equal "aaa"
		     (compat-string-trim "aaa")))
	     (1should
	      (equal "へっろ"
		     (compat-string-trim "へっろ")))
	     (1should
	      (equal "hello world"
		     (compat-string-trim "hello world")))
	     (1should
	      (equal "a"
		     (compat-string-trim "a ")))
	     (1should
	      (equal "aaa"
		     (compat-string-trim "aaa ")))
	     (1should
	      (equal "a"
		     (compat-string-trim "a    ")))
	     (1should
	      (equal "a"
		     (compat-string-trim "a		")))
	     (1should
	      (equal "a"
		     (compat-string-trim "a\n  	")))
	     (1should
	      (equal "a"
		     (compat-string-trim " a")))
	     (1should
	      (equal "aaa"
		     (compat-string-trim " aaa")))
	     (1should
	      (equal "a"
		     (compat-string-trim "a")))
	     (1should
	      (equal "a"
		     (compat-string-trim "		a")))
	     (1should
	      (equal "a"
		     (compat-string-trim "\n  	a")))
	     (1should
	      (equal "a"
		     (compat-string-trim " a ")))
	     (1should
	      (equal "aaa"
		     (compat-string-trim " aaa  ")))
	     (1should
	      (equal "t	a"
		     (compat-string-trim "t	a	\n")))
	     (1should
	      (equal "a"
		     (compat-string-trim "\n  	a  \n"))))
(ert-deftest compat-impl-compat-string-trim nil "Check if compat `compat-string-trim' works as expected."
	     (1should
	      (equal ""
		     (compat--compat-string-trim "")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim "a")))
	     (1should
	      (equal "aaa"
		     (compat--compat-string-trim "aaa")))
	     (1should
	      (equal "へっろ"
		     (compat--compat-string-trim "へっろ")))
	     (1should
	      (equal "hello world"
		     (compat--compat-string-trim "hello world")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim "a ")))
	     (1should
	      (equal "aaa"
		     (compat--compat-string-trim "aaa ")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim "a    ")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim "a		")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim "a\n  	")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim " a")))
	     (1should
	      (equal "aaa"
		     (compat--compat-string-trim " aaa")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim "a")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim "		a")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim "\n  	a")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim " a ")))
	     (1should
	      (equal "aaa"
		     (compat--compat-string-trim " aaa  ")))
	     (1should
	      (equal "t	a"
		     (compat--compat-string-trim "t	a	\n")))
	     (1should
	      (equal "a"
		     (compat--compat-string-trim "\n  	a  \n"))))
(ert-deftest compat-ref-mapcan nil "Check if the real `mapcan' works as expected."
	     (1should
	      (equal nil
		     (mapcan #'identity nil)))
	     (1should
	      (equal
	       (list 1)
	       (mapcan #'identity
		       (list
			(list 1)))))
	     (1should
	      (equal
	       (list 1 2 3 4)
	       (mapcan #'identity
		       (list
			(list 1)
			(list 2 3)
			(list 4)))))
	     (1should
	      (equal
	       (list
		(list 1)
		(list 2 3)
		(list 4))
	       (mapcan #'list
		       (list
			(list 1)
			(list 2 3)
			(list 4)))))
	     (1should
	      (equal
	       (list 1 2 3 4)
	       (mapcan #'identity
		       (list
			(list 1)
			(list)
			(list 2 3)
			(list 4)))))
	     (1should
	      (equal
	       (list
		(list 1)
		(list)
		(list 2 3)
		(list 4))
	       (mapcan #'list
		       (list
			(list 1)
			(list)
			(list 2 3)
			(list 4)))))
	     (1should
	      (equal
	       (list)
	       (mapcan #'identity
		       (list
			(list)
			(list)
			(list)
			(list))))))
(ert-deftest compat-impl-mapcan nil "Check if compat `mapcan' works as expected."
	     (1should
	      (equal nil
		     (compat--mapcan #'identity nil)))
	     (1should
	      (equal
	       (list 1)
	       (compat--mapcan #'identity
			       (list
				(list 1)))))
	     (1should
	      (equal
	       (list 1 2 3 4)
	       (compat--mapcan #'identity
			       (list
				(list 1)
				(list 2 3)
				(list 4)))))
	     (1should
	      (equal
	       (list
		(list 1)
		(list 2 3)
		(list 4))
	       (compat--mapcan #'list
			       (list
				(list 1)
				(list 2 3)
				(list 4)))))
	     (1should
	      (equal
	       (list 1 2 3 4)
	       (compat--mapcan #'identity
			       (list
				(list 1)
				(list)
				(list 2 3)
				(list 4)))))
	     (1should
	      (equal
	       (list
		(list 1)
		(list)
		(list 2 3)
		(list 4))
	       (compat--mapcan #'list
			       (list
				(list 1)
				(list)
				(list 2 3)
				(list 4)))))
	     (1should
	      (equal
	       (list)
	       (compat--mapcan #'identity
			       (list
				(list)
				(list)
				(list)
				(list))))))


;; Note: as the cXXX+r implementations are relatively trivial, their
;; tests are not as extensive.

(defvar compat-cXXXr-test
  '(((a . b) . (c . d)) . ((e . f) . (g . h)))
  "Testcase for cXXXr functions.")

(defvar compat-cXXXXr-test
  '((((a . b) . (c . d)) . ((e . f) . (g . h))) .
    (((i . j) . (k . l)) . ((m . j) . (o . p))))
  "Testcase for cXXXXr functions.")(ert-deftest compat-ref-caaar nil "Check if the real `caaar' works as expected."
	     (1should
	      (equal nil
		     (car
		      (car
		       (car nil)))))
	     (1should
	      (equal 'a
		     (car
		      (car
		       (car compat-cXXXr-test))))))
(ert-deftest compat-impl-caaar nil "Check if compat `caaar' works as expected."
	     (1should
	      (equal nil
		     (compat--caaar nil)))
	     (1should
	      (equal 'a
		     (compat--caaar compat-cXXXr-test))))
(ert-deftest compat-ref-caadr nil "Check if the real `caadr' works as expected."
	     (1should
	      (equal nil
		     (car
		      (car
		       (cdr nil)))))
	     (1should
	      (equal 'e
		     (car
		      (car
		       (cdr compat-cXXXr-test))))))
(ert-deftest compat-impl-caadr nil "Check if compat `caadr' works as expected."
	     (1should
	      (equal nil
		     (compat--caadr nil)))
	     (1should
	      (equal 'e
		     (compat--caadr compat-cXXXr-test))))
(ert-deftest compat-ref-cadar nil "Check if the real `cadar' works as expected."
	     (1should
	      (equal nil
		     (car
		      (cdr
		       (car nil)))))
	     (1should
	      (equal 'c
		     (car
		      (cdr
		       (car compat-cXXXr-test))))))
(ert-deftest compat-impl-cadar nil "Check if compat `cadar' works as expected."
	     (1should
	      (equal nil
		     (compat--cadar nil)))
	     (1should
	      (equal 'c
		     (compat--cadar compat-cXXXr-test))))
(ert-deftest compat-ref-caddr nil "Check if the real `caddr' works as expected."
	     (1should
	      (equal nil
		     (car
		      (cdr
		       (cdr nil)))))
	     (1should
	      (equal 'g
		     (car
		      (cdr
		       (cdr compat-cXXXr-test))))))
(ert-deftest compat-impl-caddr nil "Check if compat `caddr' works as expected."
	     (1should
	      (equal nil
		     (compat--caddr nil)))
	     (1should
	      (equal 'g
		     (compat--caddr compat-cXXXr-test))))
(ert-deftest compat-ref-cdaar nil "Check if the real `cdaar' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (car
		       (car nil)))))
	     (1should
	      (equal 'b
		     (cdr
		      (car
		       (car compat-cXXXr-test))))))
(ert-deftest compat-impl-cdaar nil "Check if compat `cdaar' works as expected."
	     (1should
	      (equal nil
		     (compat--cdaar nil)))
	     (1should
	      (equal 'b
		     (compat--cdaar compat-cXXXr-test))))
(ert-deftest compat-ref-cdadr nil "Check if the real `cdadr' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (car
		       (cdr nil)))))
	     (1should
	      (equal 'f
		     (cdr
		      (car
		       (cdr compat-cXXXr-test))))))
(ert-deftest compat-impl-cdadr nil "Check if compat `cdadr' works as expected."
	     (1should
	      (equal nil
		     (compat--cdadr nil)))
	     (1should
	      (equal 'f
		     (compat--cdadr compat-cXXXr-test))))
(ert-deftest compat-ref-cddar nil "Check if the real `cddar' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (cdr
		       (car nil)))))
	     (1should
	      (equal 'd
		     (cdr
		      (cdr
		       (car compat-cXXXr-test))))))
(ert-deftest compat-impl-cddar nil "Check if compat `cddar' works as expected."
	     (1should
	      (equal nil
		     (compat--cddar nil)))
	     (1should
	      (equal 'd
		     (compat--cddar compat-cXXXr-test))))
(ert-deftest compat-ref-cdddr nil "Check if the real `cdddr' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (cdr
		       (cdr nil)))))
	     (1should
	      (equal 'h
		     (cdr
		      (cdr
		       (cdr compat-cXXXr-test)))))
	     #'cdddr)
(ert-deftest compat-impl-cdddr nil "Check if compat `cdddr' works as expected."
	     (1should
	      (equal nil
		     (compat--cdddr nil)))
	     (1should
	      (equal 'h
		     (compat--cdddr compat-cXXXr-test)))
	     #'cdddr)
(ert-deftest compat-ref-caaaar nil "Check if the real `caaaar' works as expected."
	     (1should
	      (equal nil
		     (car
		      (car
		       (car
			(car nil))))))
	     (1should
	      (equal 'a
		     (car
		      (car
		       (car
			(car compat-cXXXXr-test)))))))
(ert-deftest compat-impl-caaaar nil "Check if compat `caaaar' works as expected."
	     (1should
	      (equal nil
		     (compat--caaaar nil)))
	     (1should
	      (equal 'a
		     (compat--caaaar compat-cXXXXr-test))))
(ert-deftest compat-ref-caaadr nil "Check if the real `caaadr' works as expected."
	     (1should
	      (equal nil
		     (car
		      (car
		       (car
			(cdr nil))))))
	     (1should
	      (equal 'i
		     (car
		      (car
		       (car
			(cdr compat-cXXXXr-test)))))))
(ert-deftest compat-impl-caaadr nil "Check if compat `caaadr' works as expected."
	     (1should
	      (equal nil
		     (compat--caaadr nil)))
	     (1should
	      (equal 'i
		     (compat--caaadr compat-cXXXXr-test))))
(ert-deftest compat-ref-caadar nil "Check if the real `caadar' works as expected."
	     (1should
	      (equal nil
		     (car
		      (car
		       (cdr
			(car nil))))))
	     (1should
	      (equal 'e
		     (car
		      (car
		       (cdr
			(car compat-cXXXXr-test)))))))
(ert-deftest compat-impl-caadar nil "Check if compat `caadar' works as expected."
	     (1should
	      (equal nil
		     (compat--caadar nil)))
	     (1should
	      (equal 'e
		     (compat--caadar compat-cXXXXr-test))))
(ert-deftest compat-ref-caaddr nil "Check if the real `caaddr' works as expected."
	     (1should
	      (equal nil
		     (car
		      (car
		       (cdr
			(cdr nil))))))
	     (1should
	      (equal 'm
		     (car
		      (car
		       (cdr
			(cdr compat-cXXXXr-test)))))))
(ert-deftest compat-impl-caaddr nil "Check if compat `caaddr' works as expected."
	     (1should
	      (equal nil
		     (compat--caaddr nil)))
	     (1should
	      (equal 'm
		     (compat--caaddr compat-cXXXXr-test))))
(ert-deftest compat-ref-cadaar nil "Check if the real `cadaar' works as expected."
	     (1should
	      (equal nil
		     (car
		      (cdr
		       (car
			(car nil))))))
	     (1should
	      (equal 'c
		     (car
		      (cdr
		       (car
			(car compat-cXXXXr-test)))))))
(ert-deftest compat-impl-cadaar nil "Check if compat `cadaar' works as expected."
	     (1should
	      (equal nil
		     (compat--cadaar nil)))
	     (1should
	      (equal 'c
		     (compat--cadaar compat-cXXXXr-test))))
(ert-deftest compat-ref-cadadr nil "Check if the real `cadadr' works as expected."
	     (1should
	      (equal nil
		     (car
		      (cdr
		       (car
			(cdr nil))))))
	     (1should
	      (equal 'k
		     (car
		      (cdr
		       (car
			(cdr compat-cXXXXr-test)))))))
(ert-deftest compat-impl-cadadr nil "Check if compat `cadadr' works as expected."
	     (1should
	      (equal nil
		     (compat--cadadr nil)))
	     (1should
	      (equal 'k
		     (compat--cadadr compat-cXXXXr-test))))
(ert-deftest compat-ref-caddar nil "Check if the real `caddar' works as expected."
	     (1should
	      (equal nil
		     (car
		      (cdr
		       (cdr
			(car nil))))))
	     (1should
	      (equal 'g
		     (car
		      (cdr
		       (cdr
			(car compat-cXXXXr-test)))))))
(ert-deftest compat-impl-caddar nil "Check if compat `caddar' works as expected."
	     (1should
	      (equal nil
		     (compat--caddar nil)))
	     (1should
	      (equal 'g
		     (compat--caddar compat-cXXXXr-test))))
(ert-deftest compat-ref-cadddr nil "Check if the real `cadddr' works as expected."
	     (1should
	      (equal nil
		     (car
		      (cdr
		       (cdr
			(cdr nil))))))
	     (1should
	      (equal 'o
		     (car
		      (cdr
		       (cdr
			(cdr compat-cXXXXr-test)))))))
(ert-deftest compat-impl-cadddr nil "Check if compat `cadddr' works as expected."
	     (1should
	      (equal nil
		     (compat--cadddr nil)))
	     (1should
	      (equal 'o
		     (compat--cadddr compat-cXXXXr-test))))
(ert-deftest compat-ref-cdaaar nil "Check if the real `cdaaar' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (car
		       (car
			(car nil))))))
	     (1should
	      (equal 'b
		     (cdr
		      (car
		       (car
			(car compat-cXXXXr-test)))))))
(ert-deftest compat-impl-cdaaar nil "Check if compat `cdaaar' works as expected."
	     (1should
	      (equal nil
		     (compat--cdaaar nil)))
	     (1should
	      (equal 'b
		     (compat--cdaaar compat-cXXXXr-test))))
(ert-deftest compat-ref-cdaadr nil "Check if the real `cdaadr' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (car
		       (car
			(cdr nil))))))
	     (1should
	      (equal 'j
		     (cdr
		      (car
		       (car
			(cdr compat-cXXXXr-test)))))))
(ert-deftest compat-impl-cdaadr nil "Check if compat `cdaadr' works as expected."
	     (1should
	      (equal nil
		     (compat--cdaadr nil)))
	     (1should
	      (equal 'j
		     (compat--cdaadr compat-cXXXXr-test))))
(ert-deftest compat-ref-cdadar nil "Check if the real `cdadar' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (car
		       (cdr
			(car nil))))))
	     (1should
	      (equal 'f
		     (cdr
		      (car
		       (cdr
			(car compat-cXXXXr-test)))))))
(ert-deftest compat-impl-cdadar nil "Check if compat `cdadar' works as expected."
	     (1should
	      (equal nil
		     (compat--cdadar nil)))
	     (1should
	      (equal 'f
		     (compat--cdadar compat-cXXXXr-test))))
(ert-deftest compat-ref-cdaddr nil "Check if the real `cdaddr' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (car
		       (cdr
			(cdr nil))))))
	     (1should
	      (equal 'j
		     (cdr
		      (car
		       (cdr
			(cdr compat-cXXXXr-test)))))))
(ert-deftest compat-impl-cdaddr nil "Check if compat `cdaddr' works as expected."
	     (1should
	      (equal nil
		     (compat--cdaddr nil)))
	     (1should
	      (equal 'j
		     (compat--cdaddr compat-cXXXXr-test))))
(ert-deftest compat-ref-cddaar nil "Check if the real `cddaar' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (cdr
		       (car
			(car nil))))))
	     (1should
	      (equal 'd
		     (cdr
		      (cdr
		       (car
			(car compat-cXXXXr-test)))))))
(ert-deftest compat-impl-cddaar nil "Check if compat `cddaar' works as expected."
	     (1should
	      (equal nil
		     (compat--cddaar nil)))
	     (1should
	      (equal 'd
		     (compat--cddaar compat-cXXXXr-test))))
(ert-deftest compat-ref-cddadr nil "Check if the real `cddadr' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (cdr
		       (car
			(cdr nil))))))
	     (1should
	      (equal 'l
		     (cdr
		      (cdr
		       (car
			(cdr compat-cXXXXr-test)))))))
(ert-deftest compat-impl-cddadr nil "Check if compat `cddadr' works as expected."
	     (1should
	      (equal nil
		     (compat--cddadr nil)))
	     (1should
	      (equal 'l
		     (compat--cddadr compat-cXXXXr-test))))
(ert-deftest compat-ref-cdddar nil "Check if the real `cdddar' works as expected."
	     (1should
	      (equal nil
		     (cdr
		      (cdr
		       (cdr
			(car nil))))))
	     (1should
	      (equal 'h
		     (cdr
		      (cdr
		       (cdr
			(car compat-cXXXXr-test)))))))
(ert-deftest compat-impl-cdddar nil "Check if compat `cdddar' works as expected."
	     (1should
	      (equal nil
		     (compat--cdddar nil)))
	     (1should
	      (equal 'h
		     (compat--cdddar compat-cXXXXr-test))))
(ert-deftest compat-ref-string-greaterp nil "Check if the real `string-greaterp' works as expected."
	     (1should
	      (equal t
		     (string-greaterp "b" "a")))
	     (1should
	      (equal nil
		     (string-greaterp "a" "b")))
	     (1should
	      (equal t
		     (string-greaterp "aaab" "aaaa")))
	     (1should
	      (equal nil
		     (string-greaterp "aaaa" "aaab"))))
(ert-deftest compat-impl-string-greaterp nil "Check if compat `string-greaterp' works as expected."
	     (1should
	      (equal t
		     (compat--string-greaterp "b" "a")))
	     (1should
	      (equal nil
		     (compat--string-greaterp "a" "b")))
	     (1should
	      (equal t
		     (compat--string-greaterp "aaab" "aaaa")))
	     (1should
	      (equal nil
		     (compat--string-greaterp "aaaa" "aaab"))))
(ert-deftest compat-ref-compat-sort nil "Check if the real `compat-sort' works as expected."
	     (1should
	      (equal
	       (list 1 2 3)
	       (compat-sort
		(list 1 2 3)
		#'<)))
	     (1should
	      (equal
	       (list 1 2 3)
	       (compat-sort
		(list 3 2 1)
		#'<)))
	     (1should
	      (equal
	       '[1 2 3]
	       (compat-sort
		'[1 2 3]
		#'<)))
	     (1should
	      (equal
	       '[1 2 3]
	       (compat-sort
		'[3 2 1]
		#'<))))
(ert-deftest compat-impl-compat-sort nil "Check if compat `compat-sort' works as expected."
	     (1should
	      (equal
	       (list 1 2 3)
	       (compat--compat-sort
		(list 1 2 3)
		#'<)))
	     (1should
	      (equal
	       (list 1 2 3)
	       (compat--compat-sort
		(list 3 2 1)
		#'<)))
	     (1should
	      (equal
	       '[1 2 3]
	       (compat--compat-sort
		'[1 2 3]
		#'<)))
	     (1should
	      (equal
	       '[1 2 3]
	       (compat--compat-sort
		'[3 2 1]
		#'<))))
(ert-deftest compat-ref-compat-= nil "Check if the real `compat-=' works as expected."
	     (1should
	      (equal t
		     (compat-= 0 0)))
	     (1should
	      (equal t
		     (compat-= 0 0 0)))
	     (1should
	      (equal t
		     (compat-= 0 0 0 0)))
	     (1should
	      (equal t
		     (compat-= 0 0 0 0 0)))
	     (1should
	      (equal t
		     (compat-= 0.0 0.0)))
	     (1should
	      (equal t
		     (compat-= 0.0 -0.0)))
	     (1should
	      (equal t
		     (compat-= 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat-= 0.0 0.0 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat-= 0 1)))
	     (1should
	      (equal nil
		     (compat-= 0 0 1)))
	     (1should
	      (equal nil
		     (compat-= 0 0 0 0 1)))
	     (expect wrong-type-argument 0 0 'a)
	     (1should
	      (equal nil
		     (compat-= 0 1 'a)))
	     (1should
	      (equal nil
		     (compat-= 0.0 0.0 0.0 0.1))))
(ert-deftest compat-impl-compat-= nil "Check if compat `compat-=' works as expected."
	     (1should
	      (equal t
		     (compat--compat-= 0 0)))
	     (1should
	      (equal t
		     (compat--compat-= 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat-= 0 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat-= 0 0 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat-= 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat-= 0.0 -0.0)))
	     (1should
	      (equal t
		     (compat--compat-= 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat-= 0.0 0.0 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat--compat-= 0 1)))
	     (1should
	      (equal nil
		     (compat--compat-= 0 0 1)))
	     (1should
	      (equal nil
		     (compat--compat-= 0 0 0 0 1)))
	     (expect wrong-type-argument 0 0 'a)
	     (1should
	      (equal nil
		     (compat--compat-= 0 1 'a)))
	     (1should
	      (equal nil
		     (compat--compat-= 0.0 0.0 0.0 0.1))))
(ert-deftest compat-ref-compat-< nil "Check if the real `compat-<' works as expected."
	     (1should
	      (equal nil
		     (compat-< 0 0)))
	     (1should
	      (equal nil
		     (compat-< 0 0 0)))
	     (1should
	      (equal nil
		     (compat-< 0 0 0 0)))
	     (1should
	      (equal nil
		     (compat-< 0 0 0 0 0)))
	     (1should
	      (equal nil
		     (compat-< 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat-< 0.0 -0.0)))
	     (1should
	      (equal nil
		     (compat-< 0.0 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat-< 0.0 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat-< 0 1)))
	     (1should
	      (equal nil
		     (compat-< 1 0)))
	     (1should
	      (equal nil
		     (compat-< 0 0 1)))
	     (1should
	      (equal t
		     (compat-< 0 1 2)))
	     (1should
	      (equal nil
		     (compat-< 2 1 0)))
	     (1should
	      (equal nil
		     (compat-< 0 0 0 0 1)))
	     (1should
	      (equal t
		     (compat-< 0 1 2 3 4)))
	     (expect wrong-type-argument 0 1 'a)
	     (1should
	      (equal nil
		     (compat-< 0 0 'a)))
	     (1should
	      (equal nil
		     (compat-< 0.0 0.0 0.0 0.1)))
	     (1should
	      (equal t
		     (compat-< -0.1 0.0 0.2 0.4)))
	     (1should
	      (equal t
		     (compat-< -0.1 0 0.2 0.4))))
(ert-deftest compat-impl-compat-< nil "Check if compat `compat-<' works as expected."
	     (1should
	      (equal nil
		     (compat--compat-< 0 0)))
	     (1should
	      (equal nil
		     (compat--compat-< 0 0 0)))
	     (1should
	      (equal nil
		     (compat--compat-< 0 0 0 0)))
	     (1should
	      (equal nil
		     (compat--compat-< 0 0 0 0 0)))
	     (1should
	      (equal nil
		     (compat--compat-< 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat--compat-< 0.0 -0.0)))
	     (1should
	      (equal nil
		     (compat--compat-< 0.0 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat--compat-< 0.0 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat-< 0 1)))
	     (1should
	      (equal nil
		     (compat--compat-< 1 0)))
	     (1should
	      (equal nil
		     (compat--compat-< 0 0 1)))
	     (1should
	      (equal t
		     (compat--compat-< 0 1 2)))
	     (1should
	      (equal nil
		     (compat--compat-< 2 1 0)))
	     (1should
	      (equal nil
		     (compat--compat-< 0 0 0 0 1)))
	     (1should
	      (equal t
		     (compat--compat-< 0 1 2 3 4)))
	     (expect wrong-type-argument 0 1 'a)
	     (1should
	      (equal nil
		     (compat--compat-< 0 0 'a)))
	     (1should
	      (equal nil
		     (compat--compat-< 0.0 0.0 0.0 0.1)))
	     (1should
	      (equal t
		     (compat--compat-< -0.1 0.0 0.2 0.4)))
	     (1should
	      (equal t
		     (compat--compat-< -0.1 0 0.2 0.4))))
(ert-deftest compat-ref-compat-> nil "Check if the real `compat->' works as expected."
	     (1should
	      (equal nil
		     (compat-> 0 0)))
	     (1should
	      (equal nil
		     (compat-> 0 0 0)))
	     (1should
	      (equal nil
		     (compat-> 0 0 0 0)))
	     (1should
	      (equal nil
		     (compat-> 0 0 0 0 0)))
	     (1should
	      (equal nil
		     (compat-> 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat-> 0.0 -0.0)))
	     (1should
	      (equal nil
		     (compat-> 0.0 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat-> 0.0 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat-> 1 0)))
	     (1should
	      (equal nil
		     (compat-> 1 0 0)))
	     (1should
	      (equal nil
		     (compat-> 0 1 2)))
	     (1should
	      (equal t
		     (compat-> 2 1 0)))
	     (1should
	      (equal nil
		     (compat-> 1 0 0 0 0)))
	     (1should
	      (equal t
		     (compat-> 4 3 2 1 0)))
	     (1should
	      (equal nil
		     (compat-> 4 3 2 1 1)))
	     (expect wrong-type-argument 1 0 'a)
	     (1should
	      (equal nil
		     (compat-> 0 0 'a)))
	     (1should
	      (equal nil
		     (compat-> 0.1 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat-> 0.4 0.2 0.0 -0.1)))
	     (1should
	      (equal t
		     (compat-> 0.4 0.2 0 -0.1))))
(ert-deftest compat-impl-compat-> nil "Check if compat `compat->' works as expected."
	     (1should
	      (equal nil
		     (compat--compat-> 0 0)))
	     (1should
	      (equal nil
		     (compat--compat-> 0 0 0)))
	     (1should
	      (equal nil
		     (compat--compat-> 0 0 0 0)))
	     (1should
	      (equal nil
		     (compat--compat-> 0 0 0 0 0)))
	     (1should
	      (equal nil
		     (compat--compat-> 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat--compat-> 0.0 -0.0)))
	     (1should
	      (equal nil
		     (compat--compat-> 0.0 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat--compat-> 0.0 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat-> 1 0)))
	     (1should
	      (equal nil
		     (compat--compat-> 1 0 0)))
	     (1should
	      (equal nil
		     (compat--compat-> 0 1 2)))
	     (1should
	      (equal t
		     (compat--compat-> 2 1 0)))
	     (1should
	      (equal nil
		     (compat--compat-> 1 0 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat-> 4 3 2 1 0)))
	     (1should
	      (equal nil
		     (compat--compat-> 4 3 2 1 1)))
	     (expect wrong-type-argument 1 0 'a)
	     (1should
	      (equal nil
		     (compat--compat-> 0 0 'a)))
	     (1should
	      (equal nil
		     (compat--compat-> 0.1 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat-> 0.4 0.2 0.0 -0.1)))
	     (1should
	      (equal t
		     (compat--compat-> 0.4 0.2 0 -0.1))))
(ert-deftest compat-ref-compat-<= nil "Check if the real `compat-<=' works as expected."
	     (1should
	      (equal t
		     (compat-<= 0 0)))
	     (1should
	      (equal t
		     (compat-<= 0 0 0)))
	     (1should
	      (equal t
		     (compat-<= 0 0 0 0)))
	     (1should
	      (equal t
		     (compat-<= 0 0 0 0 0)))
	     (1should
	      (equal t
		     (compat-<= 0.0 0.0)))
	     (1should
	      (equal t
		     (compat-<= 0.0 -0.0)))
	     (1should
	      (equal t
		     (compat-<= 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat-<= 0.0 0.0 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat-<= 1 0)))
	     (1should
	      (equal nil
		     (compat-<= 1 0 0)))
	     (1should
	      (equal t
		     (compat-<= 0 1 2)))
	     (1should
	      (equal nil
		     (compat-<= 2 1 0)))
	     (1should
	      (equal nil
		     (compat-<= 1 0 0 0 0)))
	     (1should
	      (equal nil
		     (compat-<= 4 3 2 1 0)))
	     (1should
	      (equal nil
		     (compat-<= 4 3 2 1 1)))
	     (1should
	      (equal t
		     (compat-<= 0 1 2 3 4)))
	     (1should
	      (equal t
		     (compat-<= 1 1 2 3 4)))
	     (expect wrong-type-argument 0 0 'a)
	     (expect wrong-type-argument 0 1 'a)
	     (1should
	      (equal nil
		     (compat-<= 1 0 'a)))
	     (1should
	      (equal nil
		     (compat-<= 0.1 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat-<= 0.0 0.0 0.0 0.1)))
	     (1should
	      (equal t
		     (compat-<= -0.1 0.0 0.2 0.4)))
	     (1should
	      (equal t
		     (compat-<= -0.1 0.0 0.0 0.2 0.4)))
	     (1should
	      (equal t
		     (compat-<= -0.1 0.0 0 0.2 0.4)))
	     (1should
	      (equal t
		     (compat-<= -0.1 0 0.2 0.4)))
	     (1should
	      (equal nil
		     (compat-<= 0.4 0.2 0.0 -0.1)))
	     (1should
	      (equal nil
		     (compat-<= 0.4 0.2 0.0 0.0 -0.1)))
	     (1should
	      (equal nil
		     (compat-<= 0.4 0.2 0 0.0 0.0 -0.1)))
	     (1should
	      (equal nil
		     (compat-<= 0.4 0.2 0 -0.1))))
(ert-deftest compat-impl-compat-<= nil "Check if compat `compat-<=' works as expected."
	     (1should
	      (equal t
		     (compat--compat-<= 0 0)))
	     (1should
	      (equal t
		     (compat--compat-<= 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat-<= 0 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat-<= 0 0 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat-<= 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat-<= 0.0 -0.0)))
	     (1should
	      (equal t
		     (compat--compat-<= 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat-<= 0.0 0.0 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat--compat-<= 1 0)))
	     (1should
	      (equal nil
		     (compat--compat-<= 1 0 0)))
	     (1should
	      (equal t
		     (compat--compat-<= 0 1 2)))
	     (1should
	      (equal nil
		     (compat--compat-<= 2 1 0)))
	     (1should
	      (equal nil
		     (compat--compat-<= 1 0 0 0 0)))
	     (1should
	      (equal nil
		     (compat--compat-<= 4 3 2 1 0)))
	     (1should
	      (equal nil
		     (compat--compat-<= 4 3 2 1 1)))
	     (1should
	      (equal t
		     (compat--compat-<= 0 1 2 3 4)))
	     (1should
	      (equal t
		     (compat--compat-<= 1 1 2 3 4)))
	     (expect wrong-type-argument 0 0 'a)
	     (expect wrong-type-argument 0 1 'a)
	     (1should
	      (equal nil
		     (compat--compat-<= 1 0 'a)))
	     (1should
	      (equal nil
		     (compat--compat-<= 0.1 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat-<= 0.0 0.0 0.0 0.1)))
	     (1should
	      (equal t
		     (compat--compat-<= -0.1 0.0 0.2 0.4)))
	     (1should
	      (equal t
		     (compat--compat-<= -0.1 0.0 0.0 0.2 0.4)))
	     (1should
	      (equal t
		     (compat--compat-<= -0.1 0.0 0 0.2 0.4)))
	     (1should
	      (equal t
		     (compat--compat-<= -0.1 0 0.2 0.4)))
	     (1should
	      (equal nil
		     (compat--compat-<= 0.4 0.2 0.0 -0.1)))
	     (1should
	      (equal nil
		     (compat--compat-<= 0.4 0.2 0.0 0.0 -0.1)))
	     (1should
	      (equal nil
		     (compat--compat-<= 0.4 0.2 0 0.0 0.0 -0.1)))
	     (1should
	      (equal nil
		     (compat--compat-<= 0.4 0.2 0 -0.1))))
(ert-deftest compat-ref-compat->= nil "Check if the real `compat->=' works as expected."
	     (1should
	      (equal t
		     (compat->= 0 0)))
	     (1should
	      (equal t
		     (compat->= 0 0 0)))
	     (1should
	      (equal t
		     (compat->= 0 0 0 0)))
	     (1should
	      (equal t
		     (compat->= 0 0 0 0 0)))
	     (1should
	      (equal t
		     (compat->= 0.0 0.0)))
	     (1should
	      (equal t
		     (compat->= 0.0 -0.0)))
	     (1should
	      (equal t
		     (compat->= 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat->= 0.0 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat->= 1 0)))
	     (1should
	      (equal t
		     (compat->= 1 0 0)))
	     (1should
	      (equal nil
		     (compat->= 0 1 2)))
	     (1should
	      (equal t
		     (compat->= 2 1 0)))
	     (1should
	      (equal t
		     (compat->= 1 0 0 0 0)))
	     (1should
	      (equal t
		     (compat->= 4 3 2 1 0)))
	     (1should
	      (equal t
		     (compat->= 4 3 2 1 1)))
	     (expect wrong-type-argument 0 0 'a)
	     (expect wrong-type-argument 1 0 'a)
	     (1should
	      (equal nil
		     (compat->= 0 1 'a)))
	     (1should
	      (equal t
		     (compat->= 0.1 0.0 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat->= 0.0 0.0 0.0 0.1)))
	     (1should
	      (equal nil
		     (compat->= -0.1 0.0 0.2 0.4)))
	     (1should
	      (equal nil
		     (compat->= -0.1 0.0 0.0 0.2 0.4)))
	     (1should
	      (equal nil
		     (compat->= -0.1 0.0 0 0.2 0.4)))
	     (1should
	      (equal nil
		     (compat->= -0.1 0 0.2 0.4)))
	     (1should
	      (equal t
		     (compat->= 0.4 0.2 0.0 -0.1)))
	     (1should
	      (equal t
		     (compat->= 0.4 0.2 0.0 0.0 -0.1)))
	     (1should
	      (equal t
		     (compat->= 0.4 0.2 0 0.0 0.0 -0.1)))
	     (1should
	      (equal t
		     (compat->= 0.4 0.2 0 -0.1))))
(ert-deftest compat-impl-compat->= nil "Check if compat `compat->=' works as expected."
	     (1should
	      (equal t
		     (compat--compat->= 0 0)))
	     (1should
	      (equal t
		     (compat--compat->= 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat->= 0 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat->= 0 0 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat->= 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat->= 0.0 -0.0)))
	     (1should
	      (equal t
		     (compat--compat->= 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat->= 0.0 0.0 0.0 0.0)))
	     (1should
	      (equal t
		     (compat--compat->= 1 0)))
	     (1should
	      (equal t
		     (compat--compat->= 1 0 0)))
	     (1should
	      (equal nil
		     (compat--compat->= 0 1 2)))
	     (1should
	      (equal t
		     (compat--compat->= 2 1 0)))
	     (1should
	      (equal t
		     (compat--compat->= 1 0 0 0 0)))
	     (1should
	      (equal t
		     (compat--compat->= 4 3 2 1 0)))
	     (1should
	      (equal t
		     (compat--compat->= 4 3 2 1 1)))
	     (expect wrong-type-argument 0 0 'a)
	     (expect wrong-type-argument 1 0 'a)
	     (1should
	      (equal nil
		     (compat--compat->= 0 1 'a)))
	     (1should
	      (equal t
		     (compat--compat->= 0.1 0.0 0.0 0.0)))
	     (1should
	      (equal nil
		     (compat--compat->= 0.0 0.0 0.0 0.1)))
	     (1should
	      (equal nil
		     (compat--compat->= -0.1 0.0 0.2 0.4)))
	     (1should
	      (equal nil
		     (compat--compat->= -0.1 0.0 0.0 0.2 0.4)))
	     (1should
	      (equal nil
		     (compat--compat->= -0.1 0.0 0 0.2 0.4)))
	     (1should
	      (equal nil
		     (compat--compat->= -0.1 0 0.2 0.4)))
	     (1should
	      (equal t
		     (compat--compat->= 0.4 0.2 0.0 -0.1)))
	     (1should
	      (equal t
		     (compat--compat->= 0.4 0.2 0.0 0.0 -0.1)))
	     (1should
	      (equal t
		     (compat--compat->= 0.4 0.2 0 0.0 0.0 -0.1)))
	     (1should
	      (equal t
		     (compat--compat->= 0.4 0.2 0 -0.1))))
(ert-deftest compat-ref-special-form-p nil "Check if the real `special-form-p' works as expected."
	     (1should
	      (equal t
		     (special-form-p 'if)))
	     (1should
	      (equal t
		     (special-form-p 'cond)))
	     (1should
	      (equal nil
		     (special-form-p 'when)))
	     (1should
	      (equal nil
		     (special-form-p 'defun)))
	     (1should
	      (equal nil
		     (special-form-p '+)))
	     (1should
	      (equal nil
		     (special-form-p nil)))
	     (1should
	      (equal nil
		     (special-form-p "macro")))
	     (1should
	      (equal nil
		     (special-form-p
		      '(macro . +)))))
(ert-deftest compat-impl-special-form-p nil "Check if compat `special-form-p' works as expected."
	     (1should
	      (equal t
		     (compat--special-form-p 'if)))
	     (1should
	      (equal t
		     (compat--special-form-p 'cond)))
	     (1should
	      (equal nil
		     (compat--special-form-p 'when)))
	     (1should
	      (equal nil
		     (compat--special-form-p 'defun)))
	     (1should
	      (equal nil
		     (compat--special-form-p '+)))
	     (1should
	      (equal nil
		     (compat--special-form-p nil)))
	     (1should
	      (equal nil
		     (compat--special-form-p "macro")))
	     (1should
	      (equal nil
		     (compat--special-form-p
		      '(macro . +)))))
(ert-deftest compat-ref-macrop nil "Check if the real `macrop' works as expected."
	     (1should
	      (equal t
		     (macrop 'lambda)))
	     (1should
	      (equal t
		     (macrop 'defun)))
	     (1should
	      (equal t
		     (macrop 'defmacro)))
	     (1should
	      (equal nil
		     (macrop 'defalias)))
	     (1should
	      (equal nil
		     (macrop 'foobar)))
	     (1should
	      (equal nil
		     (macrop 'if)))
	     (1should
	      (equal nil
		     (macrop '+)))
	     (1should
	      (equal nil
		     (macrop 1)))
	     (1should
	      (equal nil
		     (macrop nil)))
	     (1should
	      (equal nil
		     (macrop "macro")))
	     (1should
	      (equal t
		     (macrop
		      '(macro . +)))))
(ert-deftest compat-impl-macrop nil "Check if compat `macrop' works as expected."
	     (1should
	      (equal t
		     (compat--macrop 'lambda)))
	     (1should
	      (equal t
		     (compat--macrop 'defun)))
	     (1should
	      (equal t
		     (compat--macrop 'defmacro)))
	     (1should
	      (equal nil
		     (compat--macrop 'defalias)))
	     (1should
	      (equal nil
		     (compat--macrop 'foobar)))
	     (1should
	      (equal nil
		     (compat--macrop 'if)))
	     (1should
	      (equal nil
		     (compat--macrop '+)))
	     (1should
	      (equal nil
		     (compat--macrop 1)))
	     (1should
	      (equal nil
		     (compat--macrop nil)))
	     (1should
	      (equal nil
		     (compat--macrop "macro")))
	     (1should
	      (equal t
		     (compat--macrop
		      '(macro . +)))))
(ert-deftest compat-ref-string-suffix-p nil "Check if the real `string-suffix-p' works as expected."
	     (1should
	      (equal t
		     (string-suffix-p "a" "abba")))
	     (1should
	      (equal t
		     (string-suffix-p "ba" "abba")))
	     (1should
	      (equal t
		     (string-suffix-p "abba" "abba")))
	     (1should
	      (equal nil
		     (string-suffix-p "a" "ABBA")))
	     (1should
	      (equal nil
		     (string-suffix-p "bA" "ABBA")))
	     (1should
	      (equal nil
		     (string-suffix-p "aBBA" "ABBA")))
	     (1should
	      (equal nil
		     (string-suffix-p "c" "ABBA")))
	     (1should
	      (equal nil
		     (string-suffix-p "c" "abba")))
	     (1should
	      (equal nil
		     (string-suffix-p "cddc" "abba")))
	     (1should
	      (equal nil
		     (string-suffix-p "aabba" "abba"))))
(ert-deftest compat-impl-string-suffix-p nil "Check if compat `string-suffix-p' works as expected."
	     (1should
	      (equal t
		     (compat--string-suffix-p "a" "abba")))
	     (1should
	      (equal t
		     (compat--string-suffix-p "ba" "abba")))
	     (1should
	      (equal t
		     (compat--string-suffix-p "abba" "abba")))
	     (1should
	      (equal nil
		     (compat--string-suffix-p "a" "ABBA")))
	     (1should
	      (equal nil
		     (compat--string-suffix-p "bA" "ABBA")))
	     (1should
	      (equal nil
		     (compat--string-suffix-p "aBBA" "ABBA")))
	     (1should
	      (equal nil
		     (compat--string-suffix-p "c" "ABBA")))
	     (1should
	      (equal nil
		     (compat--string-suffix-p "c" "abba")))
	     (1should
	      (equal nil
		     (compat--string-suffix-p "cddc" "abba")))
	     (1should
	      (equal nil
		     (compat--string-suffix-p "aabba" "abba"))))
(ert-deftest compat-ref-compat-split-string nil "Check if the real `compat-split-string' works as expected."
	     (1should
	      (equal
	       '("a" "b" "c")
	       (compat-split-string "a b c")))
	     (1should
	      (equal
	       '("..a.." "..b.." "..c..")
	       (compat-split-string "..a.. ..b.. ..c..")))
	     (1should
	      (equal
	       '("a" "b" "c")
	       (compat-split-string "..a.. ..b.. ..c.." nil nil "\\.+"))))
(ert-deftest compat-impl-compat-split-string nil "Check if compat `compat-split-string' works as expected."
	     (1should
	      (equal
	       '("a" "b" "c")
	       (compat--compat-split-string "a b c")))
	     (1should
	      (equal
	       '("..a.." "..b.." "..c..")
	       (compat--compat-split-string "..a.. ..b.. ..c..")))
	     (1should
	      (equal
	       '("a" "b" "c")
	       (compat--compat-split-string "..a.. ..b.. ..c.." nil nil "\\.+"))))
(ert-deftest compat-ref-delete-consecutive-dups nil "Check if the real `delete-consecutive-dups' works as expected."
	     (1should
	      (equal
	       '(1 2 3 4)
	       (delete-consecutive-dups
		'(1 2 3 4))))
	     (1should
	      (equal
	       '(1 2 3 4)
	       (delete-consecutive-dups
		'(1 2 2 3 4 4))))
	     (1should
	      (equal
	       '(1 2 3 2 4)
	       (delete-consecutive-dups
		'(1 2 2 3 2 4 4)))))
(ert-deftest compat-impl-delete-consecutive-dups nil "Check if compat `delete-consecutive-dups' works as expected."
	     (1should
	      (equal
	       '(1 2 3 4)
	       (compat--delete-consecutive-dups
		'(1 2 3 4))))
	     (1should
	      (equal
	       '(1 2 3 4)
	       (compat--delete-consecutive-dups
		'(1 2 2 3 4 4))))
	     (1should
	      (equal
	       '(1 2 3 2 4)
	       (compat--delete-consecutive-dups
		'(1 2 2 3 2 4 4)))))
(ert-deftest compat-ref-string-clean-whitespace nil "Check if the real `string-clean-whitespace' works as expected."
	     (1should
	      (equal "a b c"
		     (string-clean-whitespace "a b c")))
	     (1should
	      (equal "a b c"
		     (string-clean-whitespace "   a b c")))
	     (1should
	      (equal "a b c"
		     (string-clean-whitespace "a b c   ")))
	     (1should
	      (equal "a b c"
		     (string-clean-whitespace "a    b c")))
	     (1should
	      (equal "a b c"
		     (string-clean-whitespace "a b    c")))
	     (1should
	      (equal "a b c"
		     (string-clean-whitespace "a    b    c")))
	     (1should
	      (equal "a b c"
		     (string-clean-whitespace "   a    b    c")))
	     (1should
	      (equal "a b c"
		     (string-clean-whitespace "a    b    c    ")))
	     (1should
	      (equal "a b c"
		     (string-clean-whitespace "   a    b    c    ")))
	     (1should
	      (equal "aa bb cc"
		     (string-clean-whitespace "aa bb cc")))
	     (1should
	      (equal "aa bb cc"
		     (string-clean-whitespace "   aa bb cc")))
	     (1should
	      (equal "aa bb cc"
		     (string-clean-whitespace "aa bb cc   ")))
	     (1should
	      (equal "aa bb cc"
		     (string-clean-whitespace "aa    bb cc")))
	     (1should
	      (equal "aa bb cc"
		     (string-clean-whitespace "aa bb    cc")))
	     (1should
	      (equal "aa bb cc"
		     (string-clean-whitespace "aa    bb    cc")))
	     (1should
	      (equal "aa bb cc"
		     (string-clean-whitespace "   aa    bb    cc")))
	     (1should
	      (equal "aa bb cc"
		     (string-clean-whitespace "aa    bb    cc    ")))
	     (1should
	      (equal "aa bb cc"
		     (string-clean-whitespace "   aa    bb    cc    "))))
(ert-deftest compat-impl-string-clean-whitespace nil "Check if compat `string-clean-whitespace' works as expected."
	     (1should
	      (equal "a b c"
		     (compat--string-clean-whitespace "a b c")))
	     (1should
	      (equal "a b c"
		     (compat--string-clean-whitespace "   a b c")))
	     (1should
	      (equal "a b c"
		     (compat--string-clean-whitespace "a b c   ")))
	     (1should
	      (equal "a b c"
		     (compat--string-clean-whitespace "a    b c")))
	     (1should
	      (equal "a b c"
		     (compat--string-clean-whitespace "a b    c")))
	     (1should
	      (equal "a b c"
		     (compat--string-clean-whitespace "a    b    c")))
	     (1should
	      (equal "a b c"
		     (compat--string-clean-whitespace "   a    b    c")))
	     (1should
	      (equal "a b c"
		     (compat--string-clean-whitespace "a    b    c    ")))
	     (1should
	      (equal "a b c"
		     (compat--string-clean-whitespace "   a    b    c    ")))
	     (1should
	      (equal "aa bb cc"
		     (compat--string-clean-whitespace "aa bb cc")))
	     (1should
	      (equal "aa bb cc"
		     (compat--string-clean-whitespace "   aa bb cc")))
	     (1should
	      (equal "aa bb cc"
		     (compat--string-clean-whitespace "aa bb cc   ")))
	     (1should
	      (equal "aa bb cc"
		     (compat--string-clean-whitespace "aa    bb cc")))
	     (1should
	      (equal "aa bb cc"
		     (compat--string-clean-whitespace "aa bb    cc")))
	     (1should
	      (equal "aa bb cc"
		     (compat--string-clean-whitespace "aa    bb    cc")))
	     (1should
	      (equal "aa bb cc"
		     (compat--string-clean-whitespace "   aa    bb    cc")))
	     (1should
	      (equal "aa bb cc"
		     (compat--string-clean-whitespace "aa    bb    cc    ")))
	     (1should
	      (equal "aa bb cc"
		     (compat--string-clean-whitespace "   aa    bb    cc    "))))
(ert-deftest compat-ref-string-fill nil "Check if the real `string-fill' works as expected."
	     (1should
	      (equal "a a a a a"
		     (string-fill "a a a a a" 9)))
	     (1should
	      (equal "a a a a a"
		     (string-fill "a a a a a" 10)))
	     (1should
	      (equal "a a a a\na"
		     (string-fill "a a a a a" 8)))
	     (1should
	      (equal "a a a a\na"
		     (string-fill "a  a  a  a  a" 8)))
	     (1should
	      (equal "a a\na a\na"
		     (string-fill "a a a a a" 4)))
	     (1should
	      (equal "a\na\na\na\na"
		     (string-fill "a a a a a" 2)))
	     (1should
	      (equal "a\na\na\na\na"
		     (string-fill "a a a a a" 1))))
(ert-deftest compat-impl-string-fill nil "Check if compat `string-fill' works as expected."
	     (1should
	      (equal "a a a a a"
		     (compat--string-fill "a a a a a" 9)))
	     (1should
	      (equal "a a a a a"
		     (compat--string-fill "a a a a a" 10)))
	     (1should
	      (equal "a a a a\na"
		     (compat--string-fill "a a a a a" 8)))
	     (1should
	      (equal "a a a a\na"
		     (compat--string-fill "a  a  a  a  a" 8)))
	     (1should
	      (equal "a a\na a\na"
		     (compat--string-fill "a a a a a" 4)))
	     (1should
	      (equal "a\na\na\na\na"
		     (compat--string-fill "a a a a a" 2)))
	     (1should
	      (equal "a\na\na\na\na"
		     (compat--string-fill "a a a a a" 1))))
(ert-deftest compat-ref-string-lines nil "Check if the real `string-lines' works as expected."
	     (1should
	      (equal
	       '("a" "b" "c")
	       (string-lines "a\nb\nc")))
	     (1should
	      (equal
	       '("a" "b" "c" "")
	       (string-lines "a\nb\nc\n")))
	     (1should
	      (equal
	       '("a" "b" "c")
	       (string-lines "a\nb\nc\n" t)))
	     (1should
	      (equal
	       '("abc" "bcd" "cde")
	       (string-lines "abc\nbcd\ncde")))
	     (1should
	      (equal
	       '(" abc" " bcd " "cde ")
	       (string-lines " abc\n bcd \ncde "))))
(ert-deftest compat-impl-string-lines nil "Check if compat `string-lines' works as expected."
	     (1should
	      (equal
	       '("a" "b" "c")
	       (compat--string-lines "a\nb\nc")))
	     (1should
	      (equal
	       '("a" "b" "c" "")
	       (compat--string-lines "a\nb\nc\n")))
	     (1should
	      (equal
	       '("a" "b" "c")
	       (compat--string-lines "a\nb\nc\n" t)))
	     (1should
	      (equal
	       '("abc" "bcd" "cde")
	       (compat--string-lines "abc\nbcd\ncde")))
	     (1should
	      (equal
	       '(" abc" " bcd " "cde ")
	       (compat--string-lines " abc\n bcd \ncde "))))
(ert-deftest compat-ref-string-pad nil "Check if the real `string-pad' works as expected."
	     (1should
	      (equal "a   "
		     (string-pad "a" 4)))
	     (1should
	      (equal "aaaa"
		     (string-pad "aaaa" 4)))
	     (1should
	      (equal "aaaaaa"
		     (string-pad "aaaaaa" 4)))
	     (1should
	      (equal "a..."
		     (string-pad "a" 4 46)))
	     (1should
	      (equal "   a"
		     (string-pad "a" 4 nil t)))
	     (1should
	      (equal "...a"
		     (string-pad "a" 4 46 t))))
(ert-deftest compat-impl-string-pad nil "Check if compat `string-pad' works as expected."
	     (1should
	      (equal "a   "
		     (compat--string-pad "a" 4)))
	     (1should
	      (equal "aaaa"
		     (compat--string-pad "aaaa" 4)))
	     (1should
	      (equal "aaaaaa"
		     (compat--string-pad "aaaaaa" 4)))
	     (1should
	      (equal "a..."
		     (compat--string-pad "a" 4 46)))
	     (1should
	      (equal "   a"
		     (compat--string-pad "a" 4 nil t)))
	     (1should
	      (equal "...a"
		     (compat--string-pad "a" 4 46 t))))
(ert-deftest compat-ref-string-chop-newline nil "Check if the real `string-chop-newline' works as expected."
	     (1should
	      (equal ""
		     (string-chop-newline "")))
	     (1should
	      (equal ""
		     (string-chop-newline "\n")))
	     (1should
	      (equal "aaa"
		     (string-chop-newline "aaa")))
	     (1should
	      (equal "aaa"
		     (string-chop-newline "aaa\n")))
	     (1should
	      (equal "aaa\n"
		     (string-chop-newline "aaa\n\n"))))
(ert-deftest compat-impl-string-chop-newline nil "Check if compat `string-chop-newline' works as expected."
	     (1should
	      (equal ""
		     (compat--string-chop-newline "")))
	     (1should
	      (equal ""
		     (compat--string-chop-newline "\n")))
	     (1should
	      (equal "aaa"
		     (compat--string-chop-newline "aaa")))
	     (1should
	      (equal "aaa"
		     (compat--string-chop-newline "aaa\n")))
	     (1should
	      (equal "aaa\n"
		     (compat--string-chop-newline "aaa\n\n"))))
(ert-deftest compat-ref-macroexpand-1 nil "Check if the real `macroexpand-1' works as expected."
	     (1should
	      (equal
	       '(if a b c)
	       (macroexpand-1
		'(if a b c))))
	     (1should
	      (equal
	       '(if a
		    (progn b))
	       (macroexpand-1
		'(when a b))))
	     (1should
	      (equal
	       '(if a
		    (progn
		      (unless b c)))
	       (macroexpand-1
		'(when a
		   (unless b c))))))
(ert-deftest compat-impl-macroexpand-1 nil "Check if compat `macroexpand-1' works as expected."
	     (1should
	      (equal
	       '(if a b c)
	       (compat--macroexpand-1
		'(if a b c))))
	     (1should
	      (equal
	       '(if a
		    (progn b))
	       (compat--macroexpand-1
		'(when a b))))
	     (1should
	      (equal
	       '(if a
		    (progn
		      (unless b c)))
	       (compat--macroexpand-1
		'(when a
		   (unless b c))))))
(ert-deftest compat-ref-compat-file-size-human-readable nil "Check if the real `compat-file-size-human-readable' works as expected."
	     (1should
	      (equal "1000"
		     (compat-file-size-human-readable 1000)))
	     (1should
	      (equal "1k"
		     (compat-file-size-human-readable 1024)))
	     (1should
	      (equal "1M"
		     (compat-file-size-human-readable
		      (* 1024 1024))))
	     (1should
	      (equal "1G"
		     (compat-file-size-human-readable
		      (expt 1024 3))))
	     (1should
	      (equal "1T"
		     (compat-file-size-human-readable
		      (expt 1024 4))))
	     (1should
	      (equal "1k"
		     (compat-file-size-human-readable 1000 'si)))
	     (1should
	      (equal "1KiB"
		     (compat-file-size-human-readable 1024 'iec)))
	     (1should
	      (equal "1KiB"
		     (compat-file-size-human-readable 1024 'iec)))
	     (1should
	      (equal "1 KiB"
		     (compat-file-size-human-readable 1024 'iec " ")))
	     (1should
	      (equal "1KiA"
		     (compat-file-size-human-readable 1024 'iec nil "A")))
	     (1should
	      (equal "1 KiA"
		     (compat-file-size-human-readable 1024 'iec " " "A")))
	     (1should
	      (equal "1kA"
		     (compat-file-size-human-readable 1000 'si nil "A")))
	     (1should
	      (equal "1 k"
		     (compat-file-size-human-readable 1000 'si " ")))
	     (1should
	      (equal "1 kA"
		     (compat-file-size-human-readable 1000 'si " " "A"))))
(ert-deftest compat-impl-compat-file-size-human-readable nil "Check if compat `compat-file-size-human-readable' works as expected."
	     (1should
	      (equal "1000"
		     (compat--compat-file-size-human-readable 1000)))
	     (1should
	      (equal "1k"
		     (compat--compat-file-size-human-readable 1024)))
	     (1should
	      (equal "1M"
		     (compat--compat-file-size-human-readable
		      (* 1024 1024))))
	     (1should
	      (equal "1G"
		     (compat--compat-file-size-human-readable
		      (expt 1024 3))))
	     (1should
	      (equal "1T"
		     (compat--compat-file-size-human-readable
		      (expt 1024 4))))
	     (1should
	      (equal "1k"
		     (compat--compat-file-size-human-readable 1000 'si)))
	     (1should
	      (equal "1KiB"
		     (compat--compat-file-size-human-readable 1024 'iec)))
	     (1should
	      (equal "1KiB"
		     (compat--compat-file-size-human-readable 1024 'iec)))
	     (1should
	      (equal "1 KiB"
		     (compat--compat-file-size-human-readable 1024 'iec " ")))
	     (1should
	      (equal "1KiA"
		     (compat--compat-file-size-human-readable 1024 'iec nil "A")))
	     (1should
	      (equal "1 KiA"
		     (compat--compat-file-size-human-readable 1024 'iec " " "A")))
	     (1should
	      (equal "1kA"
		     (compat--compat-file-size-human-readable 1000 'si nil "A")))
	     (1should
	      (equal "1 k"
		     (compat--compat-file-size-human-readable 1000 'si " ")))
	     (1should
	      (equal "1 kA"
		     (compat--compat-file-size-human-readable 1000 'si " " "A"))))
(ert-deftest compat-ref-format-prompt nil "Check if the real `format-prompt' works as expected."
	     (1should
	      (equal "Prompt: "
		     (format-prompt "Prompt" nil)))
	     (1should
	      (equal "Prompt: "
		     (format-prompt "Prompt" "")))
	     (1should
	      (equal "Prompt (default  ): "
		     (format-prompt "Prompt" " ")))
	     (1should
	      (equal "Prompt (default 3): "
		     (format-prompt "Prompt" 3)))
	     (1should
	      (equal "Prompt (default abc): "
		     (format-prompt "Prompt" "abc")))
	     (1should
	      (equal "Prompt (default abc def): "
		     (format-prompt "Prompt" "abc def")))
	     (1should
	      (equal "Prompt 10: "
		     (format-prompt "Prompt %d" nil 10)))
	     (1should
	      (equal "Prompt \"abc\" (default 3): "
		     (format-prompt "Prompt %S" 3 "abc"))))
(ert-deftest compat-impl-format-prompt nil "Check if compat `format-prompt' works as expected."
	     (1should
	      (equal "Prompt: "
		     (compat--format-prompt "Prompt" nil)))
	     (1should
	      (equal "Prompt: "
		     (compat--format-prompt "Prompt" "")))
	     (1should
	      (equal "Prompt (default  ): "
		     (compat--format-prompt "Prompt" " ")))
	     (1should
	      (equal "Prompt (default 3): "
		     (compat--format-prompt "Prompt" 3)))
	     (1should
	      (equal "Prompt (default abc): "
		     (compat--format-prompt "Prompt" "abc")))
	     (1should
	      (equal "Prompt (default abc def): "
		     (compat--format-prompt "Prompt" "abc def")))
	     (1should
	      (equal "Prompt 10: "
		     (compat--format-prompt "Prompt %d" nil 10)))
	     (1should
	      (equal "Prompt \"abc\" (default 3): "
		     (compat--format-prompt "Prompt %S" 3 "abc"))))


(ert-deftest compat-ref-named-let ()
  "Check if the real `named-let' works as assumed."
  (skip-unless (fboundp 'named-let))
  (should (= (named-let l ((i 0)) (if (= i 8) i (l (1+ i))))
             8))
  (should (= (named-let l ((i 0)) (if (= i 100000) i (l (1+ i))))
             100000))
  (should (= (named-let l ((i 0))
               (cond
                ((= i 100000) i)
                ((= (mod i 2) 0)
                 (l (+ i 2)))
                ((l (+ i 3)))))
             100000))
  (should (= (named-let l ((i 0) (x 1)) (if (= i 8) x (l (1+ i) (* x 2))))
             (expt 2 8)))
  (should (eq (named-let lop ((x 1))
                (if (> x 0)
                    (condition-case nil
                        (lop (1- x))
                      (arith-error 'ok))
                  (/ 1 x)))
              'ok))
  (should (eq (named-let lop ((n 10000))
                (if (> n 0)
                    (condition-case nil
                        (/ n 0)
                      (arith-error (lop (1- n))))
                  'ok))
              'ok))
  (should (eq (named-let lop ((x nil))
                (cond (x)
                      (t 'ok)))
              'ok))
  (should (eq (named-let lop ((x 100000))
                (cond ((= x 0) 'ok)
                      ((lop (1- x)))))
              'ok))
  (should (eq (named-let lop ((x 100000))
                (cond
                 ((= x -1) nil)
                 ((= x 0) 'ok)
                 ((lop -1))
                 ((lop (1- x)))))
              'ok))
  (should (eq (named-let lop ((x 10000))
                (cond ((= x 0) 'ok)
                      ((and t (lop (1- x))))))
              'ok))
  (should (eq (let ((b t))
                (named-let lop ((i 0))
                  (cond ((null i) nil) ((= i 10000) 'ok)
                        ((lop (and (setq b (not b)) (1+ i))))
                        ((lop (and (setq b (not b)) (1+ i)))))))
              'ok)))

(ert-deftest compat-impl-named-let ()
  "Check if compat `named-let' works as expected."
  (should (= (compat--named-let l ((i 0)) (if (= i 8) i (l (1+ i))))
             8))
  (should (= (compat--named-let l ((i 0)) (if (= i 100000) i (l (1+ i))))
             100000))
  (should (= (compat--named-let l ((i 0))
               (cond
                ((= i 100000) i)
                ((= (mod i 2) 0)
                 (l (+ i 2)))
                ((l (+ i 3)))))
             100000))
  (should (= (compat--named-let l ((i 0) (x 1)) (if (= i 8) x (l (1+ i) (* x 2))))
             (expt 2 8)))
  (should (eq (compat--named-let lop ((x 1))
                (if (> x 0)
                    (condition-case nil
                        (lop (1- x))
                      (arith-error 'ok))
                  (/ 1 x)))
              'ok))
  (should (eq (compat--named-let lop ((n 10000))
                (if (> n 0)
                    (condition-case nil
                        (/ n 0)
                      (arith-error (lop (1- n))))
                  'ok))
              'ok))
  (should (eq (compat--named-let lop ((x nil))
                (cond (x)
                      (t 'ok)))
              'ok))
  (should (eq (compat--named-let lop ((x 100000))
                (cond ((= x 0) 'ok)
                      ((lop (1- x)))))
              'ok))
  (should (eq (compat--named-let lop ((x 100000))
                (cond
                 ((= x -1) nil)
                 ((= x 0) 'ok)
                 ((lop -1))
                 ((lop (1- x)))))
              'ok))
  (should (eq (compat--named-let lop ((x 10000))
                (cond ((= x 0) 'ok)
                      ((and t (lop (1- x))))))
              'ok))
  (should (eq (let ((b t))
                (compat--named-let lop ((i 0))
                  (cond ((null i) nil) ((= i 10000) 'ok)
                        ((lop (and (setq b (not b)) (1+ i))))
                        ((lop (and (setq b (not b)) (1+ i)))))))
              'ok)))(ert-deftest compat-ref-directory-name-p nil "Check if the real `directory-name-p' works as expected."
	     (1should
	      (equal t
		     (directory-name-p "/")))
	     (1should
	      (equal nil
		     (directory-name-p "/file")))
	     (1should
	      (equal nil
		     (directory-name-p "/dir/file")))
	     (1should
	      (equal t
		     (directory-name-p "/dir/")))
	     (1should
	      (equal nil
		     (directory-name-p "/dir")))
	     (1should
	      (equal t
		     (directory-name-p "/dir/subdir/")))
	     (1should
	      (equal nil
		     (directory-name-p "/dir/subdir")))
	     (1should
	      (equal t
		     (directory-name-p "dir/")))
	     (1should
	      (equal nil
		     (directory-name-p "file")))
	     (1should
	      (equal nil
		     (directory-name-p "dir/file")))
	     (1should
	      (equal t
		     (directory-name-p "dir/subdir/")))
	     (1should
	      (equal nil
		     (directory-name-p "dir/subdir"))))
(ert-deftest compat-impl-directory-name-p nil "Check if compat `directory-name-p' works as expected."
	     (1should
	      (equal t
		     (compat--directory-name-p "/")))
	     (1should
	      (equal nil
		     (compat--directory-name-p "/file")))
	     (1should
	      (equal nil
		     (compat--directory-name-p "/dir/file")))
	     (1should
	      (equal t
		     (compat--directory-name-p "/dir/")))
	     (1should
	      (equal nil
		     (compat--directory-name-p "/dir")))
	     (1should
	      (equal t
		     (compat--directory-name-p "/dir/subdir/")))
	     (1should
	      (equal nil
		     (compat--directory-name-p "/dir/subdir")))
	     (1should
	      (equal t
		     (compat--directory-name-p "dir/")))
	     (1should
	      (equal nil
		     (compat--directory-name-p "file")))
	     (1should
	      (equal nil
		     (compat--directory-name-p "dir/file")))
	     (1should
	      (equal t
		     (compat--directory-name-p "dir/subdir/")))
	     (1should
	      (equal nil
		     (compat--directory-name-p "dir/subdir"))))


(ert-deftest compat-ref-if-let* ()
  "Check if the real `if-let*' works as assumed."
  (skip-unless (fboundp 'if-let*))
  (should                               ;trivial condition
   (eq (if-let* ((test t)) 'true 'false) 'true))
  (should                               ;trivial non-condition
   (eq (if-let* ((test nil)) 'true 'false) 'false))
  (should                               ;non-binding non-condition
   (eq (if-let* (((ignore))) 'true 'false) 'false))
  (should
   (if-let*
    ((x 3)
     (y 2)
     (z (+ x y))
     ((= z 5))
     (true t))
    true nil))
  (should-not
   (if-let* (((= 5 6))) t nil)))

(ert-deftest compat-impl-if-let* ()
  "Check if compat `if-let*' works as expected."
  (should                               ;trivial condition
   (eq (compat--if-let* ((test t)) 'true 'false) 'true))
  (should                               ;trivial non-condition
   (eq (compat--if-let* ((test nil)) 'true 'false) 'false))
  (should                               ;non-binding non-condition
   (eq (compat--if-let* (((ignore))) 'true 'false) 'false))
  (should
   (compat--if-let*
    ((x 3)
     (y 2)
     (z (+ x y))
     ((= z 5))
     (true t))
    true nil))
  (should-not
   (compat--if-let* (((= 5 6))) t nil)))

(ert-deftest compat-ref-if-let ()
  "Check if the real `if-let' works as assumed."
  (skip-unless (fboundp 'if-let))
  (should                               ;trivial condition
   (eq (compat--if-let ((test t)) 'true 'false) 'true))
  (should                               ;trivial non-condition
   (eq (compat--if-let ((test nil)) 'true 'false) 'false))
  (should                               ;trivial non-condition
   (eq (compat--if-let (test nil) 'true 'false) 'false))
  (should                               ;non-binding non-condition
   (eq (compat--if-let (((ignore))) 'true 'false) 'false))
  (should (compat--if-let ((e (memq 0 '(1 2 3 0 5 6))))
              e))
  (should-not (compat--if-let ((e (memq 0 '(1 2 3 5 6)))
                               (d (memq 0 '(1 2 3 0 5 6))))
                  t))
  (should-not (compat--if-let ((d (memq 0 '(1 2 3 0 5 6)))
                               (e (memq 0 '(1 2 3 5 6))))
                  t))
  (should-not
   (compat--if-let (((= 5 6))) t nil)))

(ert-deftest compat-impl-if-let ()
  "Check if compat `if-let' was implemented properly."
  (should                               ;trivial condition
   (eq (compat--if-let ((test t)) 'true 'false) 'true))
  (should                               ;trivial non-condition
   (eq (compat--if-let ((test nil)) 'true 'false) 'false))
  (should                               ;trivial non-condition
   (eq (compat--if-let (test nil) 'true 'false) 'false))
  (should                               ;non-binding non-condition
   (eq (compat--if-let (((ignore))) 'true 'false) 'false))
  (should (compat--if-let ((e (memq 0 '(1 2 3 0 5 6))))
              e))
  (should-not (compat--if-let ((e (memq 0 '(1 2 3 5 6)))
                               (d (memq 0 '(1 2 3 0 5 6))))
                  t))
  (should-not (compat--if-let ((d (memq 0 '(1 2 3 0 5 6)))
                               (e (memq 0 '(1 2 3 5 6))))
                  t))
  (should-not
   (compat--if-let (((= 5 6))) t nil)))

(ert-deftest compat-ref-and-let* ()
  "Check if the real `and-let*' works as assumed."
  (skip-unless (fboundp 'and-let*))
  (should                               ;trivial condition
   (and-let* ((test t))))
  (should                               ;trivial non-condition
   (not (and-let* ((test nil)))))
  (should                               ;non-binding non-condition
   (not (and-let* (((ignore))))))
  (should                               ;trivial body
   (and-let*
    ((x 3)
     (y 2)
     (z (+ x y))
     ((= z 5))
     (true t))
    true))
  (should                               ;no body
   (and-let*
    ((x 3)
     (y 2)
     (z (+ x y))
     ((= z 5))
     (true t))))
  (should-not
   (and-let* (((= 5 6))) t)))

(ert-deftest compat-impl-and-let* ()
  "Check if compat `compat--and-let*' works as expected."
  (should                               ;trivial condition
   (compat--and-let* ((test t))))
  (should                               ;trivial non-condition
   (not (compat--and-let* ((test nil)))))
  (should                               ;non-binding non-condition
   (not (compat--and-let* (((ignore))))))
  (should                               ;trivial body
   (compat--and-let*
    ((x 3)
     (y 2)
     (z (+ x y))
     ((= z 5))
     (true t))
    true))
  (should                               ;no body
   (compat--and-let*
    ((x 3)
     (y 2)
     (z (+ x y))
     ((= z 5))
     (true t))))
  (should-not
   (compat--and-let* (((= 5 6))) t)))(ert-deftest compat-ref-compat-json-parse-string nil "Check if the real `compat-json-parse-string' works as expected."
	     (1should
	      (equal 0
		     (compat-json-parse-string "0")))
	     (1should
	      (equal 1
		     (compat-json-parse-string "1")))
	     (1should
	      (equal 0.5
		     (compat-json-parse-string "0.5")))
	     (1should
	      (equal
	       [1 2 3]
	       (compat-json-parse-string "[1,2,3]")))
	     (1should
	      (equal
	       ["a" 2 3]
	       (compat-json-parse-string "[\"a\",2,3]")))
	     (1should
	      (equal
	       [["a" 2]
		3]
	       (compat-json-parse-string "[[\"a\",2],3]")))
	     (1should
	      (equal
	       '(("a" 2)
		 3)
	       (compat-json-parse-string "[[\"a\",2],3]" :array-type 'list)))
	     (1should
	      (equal 'foo
		     (compat-json-parse-string "null" :null-object 'foo)))
	     (1should
	      (equal
	       ["false" t]
	       (compat-json-parse-string "[false, true]" :false-object "false"))))
(ert-deftest compat-impl-compat-json-parse-string nil "Check if compat `compat-json-parse-string' works as expected."
	     (1should
	      (equal 0
		     (compat--compat-json-parse-string "0")))
	     (1should
	      (equal 1
		     (compat--compat-json-parse-string "1")))
	     (1should
	      (equal 0.5
		     (compat--compat-json-parse-string "0.5")))
	     (1should
	      (equal
	       [1 2 3]
	       (compat--compat-json-parse-string "[1,2,3]")))
	     (1should
	      (equal
	       ["a" 2 3]
	       (compat--compat-json-parse-string "[\"a\",2,3]")))
	     (1should
	      (equal
	       [["a" 2]
		3]
	       (compat--compat-json-parse-string "[[\"a\",2],3]")))
	     (1should
	      (equal
	       '(("a" 2)
		 3)
	       (compat--compat-json-parse-string "[[\"a\",2],3]" :array-type 'list)))
	     (1should
	      (equal 'foo
		     (compat--compat-json-parse-string "null" :null-object 'foo)))
	     (1should
	      (equal
	       ["false" t]
	       (compat--compat-json-parse-string "[false, true]" :false-object "false"))))


(ert-deftest compat-ref-json-parse-string ()
  "Check if the real `json-parse-string' works as assumed."
  (skip-unless (fboundp 'json-parse-string))
  (let ((input "{\"key\":[\"abc\", 2], \"yek\": null}"))
    (let ((obj (json-parse-string input :object-type 'alist)))
      (should (equal (cdr (assq 'key obj)) ["abc" 2]))
      (should (equal (cdr (assq 'yek obj)) :null)))
    (let ((obj (json-parse-string input :object-type 'plist)))
      (should (equal (plist-get obj :key) ["abc" 2]))
      (should (equal (plist-get obj :yek) :null)))
    (let ((obj (json-parse-string input)))
      (should (equal (gethash "key" obj) ["abc" 2]))
      (should (equal (gethash "yek" obj) :null)))))

(ert-deftest compat-impl-json-parse-string ()
  "Check if compat `json-parse-string' works as expected."
  (let ((input "{\"key\":[\"abc\", 2], \"yek\": null}"))
    (let ((obj (compat--json-parse-string input)))
      (should (equal (gethash "key" obj) ["abc" 2]))
      (should (equal (gethash "yek" obj) :null)))
    (let ((obj (compat--json-parse-string input :object-type 'alist)))
      (should (equal (cdr (assq 'key obj)) ["abc" 2]))
      (should (equal (cdr (assq 'yek obj)) :null)))
    (let ((obj (compat--json-parse-string input :object-type 'plist)))
      (should (equal (plist-get obj :key) ["abc" 2]))
      (should (equal (plist-get obj :yek) :null)))))

(ert-deftest compat-ref-json-serialize ()
  "Check if the real `json-serialize' works as assumed."
  (skip-unless (fboundp 'json-serialize))
  (let ((input-1 '((:key . ["abc" 2]) (yek . t)))
        (input-2 '(:key ["abc" 2] yek t))
        (input-3 (let ((ht (make-hash-table)))
                   (puthash "key" ["abc" 2] ht)
                   (puthash "yek" t ht)
                   ht)))
    (should (equal (json-serialize input-1)
                   "{\":key\":[\"abc\",2],\"yek\":true}"))
    (should (equal (json-serialize input-2)
                   "{\"key\":[\"abc\",2],\"yek\":true}"))
    (should (member (json-serialize input-2)
                    '("{\"key\":[\"abc\",2],\"yek\":true}"
                      "{\"yek\":true,\"key\":[\"abc\",2]}")))
    (should-error (json-serialize '(("a" . 1)))
                  :type '(wrong-type-argument symbolp "a"))
    (should-error (json-serialize '("a" 1))
                  :type '(wrong-type-argument symbolp "a"))
    (should-error (json-serialize '("a" 1 2))
                  :type '(wrong-type-argument symbolp "a"))
    (should-error (json-serialize '(:a 1 2))
                  :type '(wrong-type-argument consp nil))
    (should-error (json-serialize
                   (let ((ht (make-hash-table)))
                     (puthash 'a 1 ht)
                     ht))
                  :type '(wrong-type-argument stringp a))))

(ert-deftest compat-impl-json-serialize ()
  "Check if compat `json-serialize' works as assumed."
  (let ((input-1 '((:key . ["abc" 2]) (yek . t)))
        (input-2 '(:key ["abc" 2] yek t))
        (input-3 (let ((ht (make-hash-table)))
                   (puthash "key" ["abc" 2] ht)
                   (puthash "yek" t ht)
                   ht)))
    (should (equal (compat--json-serialize input-1)
                   "{\":key\":[\"abc\",2],\"yek\":true}"))
    (should (equal (compat--json-serialize input-2)
                   "{\"key\":[\"abc\",2],\"yek\":true}"))
    (should (member (compat--json-serialize input-2)
                    '("{\"key\":[\"abc\",2],\"yek\":true}"
                      "{\"yek\":true,\"key\":[\"abc\",2]}")))
    (should-error (compat--json-serialize '(("a" . 1)))
                  :type '(wrong-type-argument symbolp "a"))
    (should-error (compat--json-serialize '("a" 1))
                  :type '(wrong-type-argument symbolp "a"))
    (should-error (compat--json-serialize '("a" 1 2))
                  :type '(wrong-type-argument symbolp "a"))
    (should-error (compat--json-serialize '(:a 1 2))
                  :type '(wrong-type-argument consp nil))
    (should-error (compat--json-serialize
                   (let ((ht (make-hash-table)))
                     (puthash 'a 1 ht)
                     ht))
                  :type '(wrong-type-argument stringp a))))(ert-deftest compat-ref-compat-lookup-key nil "Check if the real `compat-lookup-key' works as expected."
	     (let
		 ((a-map
		   (make-sparse-keymap))
		  (b-map
		   (make-sparse-keymap)))
	       (define-key a-map "x" 'foo)
	       (define-key b-map "x" 'bar)
	       (1should
		(equal 'foo
		       (compat-lookup-key a-map "x")))
	       (1should
		(equal 'bar
		       (compat-lookup-key b-map "x")))
	       (1should
		(equal 'foo
		       (compat-lookup-key
			(list a-map b-map)
			"x")))
	       (1should
		(equal 'bar
		       (compat-lookup-key
			(list b-map a-map)
			"x")))))
(ert-deftest compat-impl-compat-lookup-key nil "Check if compat `compat-lookup-key' works as expected."
	     (let
		 ((a-map
		   (make-sparse-keymap))
		  (b-map
		   (make-sparse-keymap)))
	       (define-key a-map "x" 'foo)
	       (define-key b-map "x" 'bar)
	       (1should
		(equal 'foo
		       (compat--compat-lookup-key a-map "x")))
	       (1should
		(equal 'bar
		       (compat--compat-lookup-key b-map "x")))
	       (1should
		(equal 'foo
		       (compat--compat-lookup-key
			(list a-map b-map)
			"x")))
	       (1should
		(equal 'bar
		       (compat--compat-lookup-key
			(list b-map a-map)
			"x")))))


(ert-deftest compat-ref-hash-table-keys ()
  "Check if the real `hash-table-keys' work as assumed."
  (skip-unless (fboundp 'hash-table-keys))
  (let ((ht (make-hash-table)))
    (should (null (hash-table-keys ht)))
    (puthash 1 'one ht)
    (should (equal '(1) (hash-table-keys ht)))
    (puthash 1 'one ht)
    (should (equal '(1) (hash-table-keys ht)))
    (puthash 2 'two ht)
    (should (memq 1 (hash-table-keys ht)))
    (should (memq 2 (hash-table-keys ht)))
    (should (= 2 (length (hash-table-keys ht))))
    (remhash 1 ht)
    (should (equal '(2) (hash-table-keys ht)))))

(ert-deftest compat-impl-hash-table-keys ()
  "Check if compat `hash-table-keys' work as expected."
  (let ((ht (make-hash-table)))
    (should (null (compat--hash-table-keys ht)))
    (puthash 1 'one ht)
    (should (equal '(1) (compat--hash-table-keys ht)))
    (puthash 1 'one ht)
    (should (equal '(1) (compat--hash-table-keys ht)))
    (puthash 2 'two ht)
    (should (memq 1 (compat--hash-table-keys ht)))
    (should (memq 2 (compat--hash-table-keys ht)))
    (should (= 2 (length (compat--hash-table-keys ht))))
    (remhash 1 ht)
    (should (equal '(2) (compat--hash-table-keys ht)))))

(ert-deftest compat-ref-hash-table-values ()
  "Check if the real `hash-table-values' work as assumed."
  (skip-unless (fboundp 'hash-table-values))
  (let ((ht (make-hash-table)))
    (should (null (hash-table-values ht)))
    (puthash 1 'one ht)
    (should (equal '(one) (hash-table-values ht)))
    (puthash 1 'one ht)
    (should (equal '(one) (hash-table-values ht)))
    (puthash 2 'two ht)
    (should (memq 'one (hash-table-values ht)))
    (should (memq 'two (hash-table-values ht)))
    (should (= 2 (length (hash-table-values ht))))
    (remhash 1 ht)
    (should (equal '(two) (hash-table-values ht)))))

(ert-deftest compat-impl-hash-table-values ()
  "Check if compat `hash-table-values' work as expected."
  (let ((ht (make-hash-table)))
    (should (null (compat--hash-table-values ht)))
    (puthash 1 'one ht)
    (should (equal '(one) (compat--hash-table-values ht)))
    (puthash 1 'one ht)
    (should (equal '(one) (compat--hash-table-values ht)))
    (puthash 2 'two ht)
    (should (memq 'one (compat--hash-table-values ht)))
    (should (memq 'two (compat--hash-table-values ht)))
    (should (= 2 (length (compat--hash-table-values ht))))
    (remhash 1 ht)
    (should (equal '(two) (compat--hash-table-values ht)))))(ert-deftest compat-ref-string-empty-p nil "Check if the real `string-empty-p' works as expected."
	     (1should
	      (equal t
		     (string-empty-p "")))
	     (1should
	      (equal nil
		     (string-empty-p " ")))
	     (1should
	      (equal t
		     (string-empty-p
		      (make-string 0 120))))
	     (1should
	      (equal nil
		     (string-empty-p
		      (make-string 1 120)))))
(ert-deftest compat-impl-string-empty-p nil "Check if compat `string-empty-p' works as expected."
	     (1should
	      (equal t
		     (compat--string-empty-p "")))
	     (1should
	      (equal nil
		     (compat--string-empty-p " ")))
	     (1should
	      (equal t
		     (compat--string-empty-p
		      (make-string 0 120))))
	     (1should
	      (equal nil
		     (compat--string-empty-p
		      (make-string 1 120)))))
(ert-deftest compat-ref-string-join nil "Check if the real `string-join' works as expected."
	     (1should
	      (equal ""
		     (string-join
		      '(""))))
	     (1should
	      (equal ""
		     (string-join
		      '("")
		      " ")))
	     (1should
	      (equal "a"
		     (string-join
		      '("a"))))
	     (1should
	      (equal "a"
		     (string-join
		      '("a")
		      " ")))
	     (1should
	      (equal "abc"
		     (string-join
		      '("a" "b" "c"))))
	     (1should
	      (equal "a b c"
		     (string-join
		      '("a" "b" "c")
		      " "))))
(ert-deftest compat-impl-string-join nil "Check if compat `string-join' works as expected."
	     (1should
	      (equal ""
		     (compat--string-join
		      '(""))))
	     (1should
	      (equal ""
		     (compat--string-join
		      '("")
		      " ")))
	     (1should
	      (equal "a"
		     (compat--string-join
		      '("a"))))
	     (1should
	      (equal "a"
		     (compat--string-join
		      '("a")
		      " ")))
	     (1should
	      (equal "abc"
		     (compat--string-join
		      '("a" "b" "c"))))
	     (1should
	      (equal "a b c"
		     (compat--string-join
		      '("a" "b" "c")
		      " "))))
(ert-deftest compat-ref-string-blank-p nil "Check if the real `string-blank-p' works as expected."
	     (1should
	      (equal 0
		     (string-blank-p "")))
	     (1should
	      (equal 0
		     (string-blank-p " ")))
	     (1should
	      (equal 0
		     (string-blank-p
		      (make-string 0 120))))
	     (1should
	      (equal nil
		     (string-blank-p
		      (make-string 1 120)))))
(ert-deftest compat-impl-string-blank-p nil "Check if compat `string-blank-p' works as expected."
	     (1should
	      (equal 0
		     (compat--string-blank-p "")))
	     (1should
	      (equal 0
		     (compat--string-blank-p " ")))
	     (1should
	      (equal 0
		     (compat--string-blank-p
		      (make-string 0 120))))
	     (1should
	      (equal nil
		     (compat--string-blank-p
		      (make-string 1 120)))))
(ert-deftest compat-ref-string-remove-prefix nil "Check if the real `string-remove-prefix' works as expected."
	     (1should
	      (equal ""
		     (string-remove-prefix "" "")))
	     (1should
	      (equal "a"
		     (string-remove-prefix "" "a")))
	     (1should
	      (equal ""
		     (string-remove-prefix "a" "")))
	     (1should
	      (equal "bc"
		     (string-remove-prefix "a" "abc")))
	     (1should
	      (equal "abc"
		     (string-remove-prefix "c" "abc")))
	     (1should
	      (equal "bbcc"
		     (string-remove-prefix "aa" "aabbcc")))
	     (1should
	      (equal "aabbcc"
		     (string-remove-prefix "bb" "aabbcc")))
	     (1should
	      (equal "aabbcc"
		     (string-remove-prefix "cc" "aabbcc")))
	     (1should
	      (equal "aabbcc"
		     (string-remove-prefix "dd" "aabbcc"))))
(ert-deftest compat-impl-string-remove-prefix nil "Check if compat `string-remove-prefix' works as expected."
	     (1should
	      (equal ""
		     (compat--string-remove-prefix "" "")))
	     (1should
	      (equal "a"
		     (compat--string-remove-prefix "" "a")))
	     (1should
	      (equal ""
		     (compat--string-remove-prefix "a" "")))
	     (1should
	      (equal "bc"
		     (compat--string-remove-prefix "a" "abc")))
	     (1should
	      (equal "abc"
		     (compat--string-remove-prefix "c" "abc")))
	     (1should
	      (equal "bbcc"
		     (compat--string-remove-prefix "aa" "aabbcc")))
	     (1should
	      (equal "aabbcc"
		     (compat--string-remove-prefix "bb" "aabbcc")))
	     (1should
	      (equal "aabbcc"
		     (compat--string-remove-prefix "cc" "aabbcc")))
	     (1should
	      (equal "aabbcc"
		     (compat--string-remove-prefix "dd" "aabbcc"))))
(ert-deftest compat-ref-string-remove-suffix nil "Check if the real `string-remove-suffix' works as expected."
	     (1should
	      (equal ""
		     (string-remove-suffix "" "")))
	     (1should
	      (equal "a"
		     (string-remove-suffix "" "a")))
	     (1should
	      (equal ""
		     (string-remove-suffix "a" "")))
	     (1should
	      (equal "abc"
		     (string-remove-suffix "a" "abc")))
	     (1should
	      (equal "ab"
		     (string-remove-suffix "c" "abc")))
	     (1should
	      (equal "aabbcc"
		     (string-remove-suffix "aa" "aabbcc")))
	     (1should
	      (equal "aabbcc"
		     (string-remove-suffix "bb" "aabbcc")))
	     (1should
	      (equal "aabb"
		     (string-remove-suffix "cc" "aabbcc")))
	     (1should
	      (equal "aabbcc"
		     (string-remove-suffix "dd" "aabbcc"))))
(ert-deftest compat-impl-string-remove-suffix nil "Check if compat `string-remove-suffix' works as expected."
	     (1should
	      (equal ""
		     (compat--string-remove-suffix "" "")))
	     (1should
	      (equal "a"
		     (compat--string-remove-suffix "" "a")))
	     (1should
	      (equal ""
		     (compat--string-remove-suffix "a" "")))
	     (1should
	      (equal "abc"
		     (compat--string-remove-suffix "a" "abc")))
	     (1should
	      (equal "ab"
		     (compat--string-remove-suffix "c" "abc")))
	     (1should
	      (equal "aabbcc"
		     (compat--string-remove-suffix "aa" "aabbcc")))
	     (1should
	      (equal "aabbcc"
		     (compat--string-remove-suffix "bb" "aabbcc")))
	     (1should
	      (equal "aabb"
		     (compat--string-remove-suffix "cc" "aabbcc")))
	     (1should
	      (equal "aabbcc"
		     (compat--string-remove-suffix "dd" "aabbcc"))))


(let ((a (bool-vector t t nil nil))
      (b (bool-vector t nil t nil)))
  (compat-deftests bool-vector-exclusive-or
    (ought (bool-vector nil t t nil) a b)
    (ought (bool-vector nil t t nil) b a)
    (when (version<= "24.4" emacs-version)
      (expect wrong-length-argument a (bool-vector))
      (expect wrong-length-argument a b (bool-vector)))
    (expect wrong-type-argument (bool-vector) (vector))
    (expect wrong-type-argument (vector) (bool-vector))
    (expect wrong-type-argument (vector) (vector))
    (expect wrong-type-argument (bool-vector) (bool-vector) (vector))
    (expect wrong-type-argument (bool-vector) (vector) (vector))
    (expect wrong-type-argument (vector) (bool-vector) (vector))
    (expect wrong-type-argument (vector) (vector) (vector)))

  (ert-deftest compat-ref-bool-vector-exclusive-or-sideeffect ()
    "Check if the real `bool-vector-exclusive-or' handles side effects."
    (skip-unless (fboundp 'bool-vector-exclusive-or))
    (let ((c (make-bool-vector 4 nil)))
      (bool-vector-exclusive-or a b c)
      (should (equal (bool-vector nil t t nil) c))
      (should (equal (bool-vector nil t t nil) c))))

  (ert-deftest compat-impl-bool-vector-exclusive-or-sideeffect ()
    "Check if compat `bool-vector-exclusive-or' handles side effects."
    (let ((c (make-bool-vector 4 nil)))
      (compat--bool-vector-exclusive-or a b c)
      (should (equal (bool-vector nil t t nil) c))
      (should (equal (bool-vector nil t t nil) c)))))

(let ((a (bool-vector t t nil nil))
      (b (bool-vector t nil t nil)))
  (compat-deftests bool-vector-union
    (ought (bool-vector t t t nil) a b)
    (ought (bool-vector t t t nil) b a)

    (when (version<= "24.4" emacs-version)
      (expect wrong-length-argument a (bool-vector))
      (expect wrong-length-argument a b (bool-vector)))
    (expect wrong-type-argument (bool-vector) (vector))
    (expect wrong-type-argument (vector) (bool-vector))
    (expect wrong-type-argument (vector) (vector))
    (expect wrong-type-argument (bool-vector) (bool-vector) (vector))
    (expect wrong-type-argument (bool-vector) (vector) (vector))
    (expect wrong-type-argument (vector) (bool-vector) (vector))
    (expect wrong-type-argument (vector) (vector) (vector)))

  (ert-deftest compat-ref-bool-vector-union-sideeffect ()
    "Check if the real `bool-vector-union' handles side effects."
    (skip-unless (fboundp 'bool-vector-union))
    (let ((c (make-bool-vector 4 nil)))
      (bool-vector-union a b c)
      (should (equal (bool-vector t t t nil) c))))

  (ert-deftest compat-impl-bool-vector-union-sideeffect ()
    "Check if compat `bool-vector-union' handles side effects."
    (let ((c (make-bool-vector 4 nil)))
      (compat--bool-vector-union a b c)
      (should (equal (bool-vector t t t nil) c)))))

(let ((a (bool-vector t t nil nil))
      (b (bool-vector t nil t nil)))
  (compat-deftests bool-vector-intersection
    (ought (bool-vector t nil nil nil) a b)
    (ought (bool-vector t nil nil nil) b a)
    (when (version<= "24.4" emacs-version)
      (expect wrong-length-argument a (bool-vector))
      (expect wrong-length-argument a b (bool-vector)))
    (expect wrong-type-argument (bool-vector) (vector))
    (expect wrong-type-argument (vector) (bool-vector))
    (expect wrong-type-argument (vector) (vector))
    (expect wrong-type-argument (bool-vector) (bool-vector) (vector))
    (expect wrong-type-argument (bool-vector) (vector) (vector))
    (expect wrong-type-argument (vector) (bool-vector) (vector))
    (expect wrong-type-argument (vector) (vector) (vector)))

  (ert-deftest compat-ref-bool-vector-intersection-sideeffect ()
    "Check if the real `bool-vector-intersection' handles side effects."
    (skip-unless (fboundp 'bool-vector-intersection))
    (let ((c (make-bool-vector 4 nil)))
      (bool-vector-intersection a b c)
      (should (equal (bool-vector t nil nil nil) c))))

  (ert-deftest compat-impl-bool-vector-intersection-sideeffect ()
    "Check if compat `bool-vector-intersection' handles side effects."
    (let ((c (make-bool-vector 4 nil)))
      (compat--bool-vector-intersection a b c)
      (should (equal (bool-vector t nil nil nil) c)))))

(let ((a (bool-vector t t nil nil))
      (b (bool-vector t nil t nil)))
  (compat-deftests bool-vector-set-difference
    (ought (bool-vector nil t nil nil) a b)
    (ought (bool-vector nil nil t nil) b a)
    (when (version<= "24.4" emacs-version)
      (expect wrong-length-argument a (bool-vector))
      (expect wrong-length-argument a b (bool-vector)))
    (expect wrong-type-argument (bool-vector) (vector))
    (expect wrong-type-argument (vector) (bool-vector))
    (expect wrong-type-argument (vector) (vector))
    (expect wrong-type-argument (bool-vector) (bool-vector) (vector))
    (expect wrong-type-argument (bool-vector) (vector) (vector))
    (expect wrong-type-argument (vector) (bool-vector) (vector))
    (expect wrong-type-argument (vector) (vector) (vector)))

  (ert-deftest compat-ref-bool-vector-set-difference-sideeffect ()
    "Check if the real `bool-vector-set-difference' handles side effects."
    (skip-unless (fboundp 'bool-vector-set-difference))
    (let ((c (make-bool-vector 4 nil)))
      (bool-vector-set-difference a b c)
      (should (equal (bool-vector nil t nil nil) c)))
    (let ((c (make-bool-vector 4 nil)))
      (bool-vector-set-difference b a c)
      (should (equal (bool-vector nil nil t nil) c))))

  (ert-deftest compat-impl-bool-vector-set-difference-sideeffect ()
    "Check if compat `bool-vector-set-difference' handles side effects."
    (let ((c (make-bool-vector 4 nil)))
      (compat--bool-vector-set-difference a b c)
      (should (equal (bool-vector nil t nil nil) c)))
    (let ((c (make-bool-vector 4 nil)))
      (compat--bool-vector-set-difference b a c)
      (should (equal (bool-vector nil nil t nil) c)))))(ert-deftest compat-ref-bool-vector-not nil "Check if the real `bool-vector-not' works as expected."
	     (1should
	      (equal
	       (bool-vector)
	       (bool-vector-not
		(bool-vector))))
	     (1should
	      (equal
	       (bool-vector t)
	       (bool-vector-not
		(bool-vector nil))))
	     (1should
	      (equal
	       (bool-vector nil)
	       (bool-vector-not
		(bool-vector t))))
	     (1should
	      (equal
	       (bool-vector t t)
	       (bool-vector-not
		(bool-vector nil nil))))
	     (1should
	      (equal
	       (bool-vector t nil)
	       (bool-vector-not
		(bool-vector nil t))))
	     (1should
	      (equal
	       (bool-vector nil t)
	       (bool-vector-not
		(bool-vector t nil))))
	     (1should
	      (equal
	       (bool-vector nil nil)
	       (bool-vector-not
		(bool-vector t t))))
	     (expect wrong-type-argument
		     (vector))
	     (expect wrong-type-argument
		     (vector)
		     (vector)))
(ert-deftest compat-impl-bool-vector-not nil "Check if compat `bool-vector-not' works as expected."
	     (1should
	      (equal
	       (bool-vector)
	       (compat--bool-vector-not
		(bool-vector))))
	     (1should
	      (equal
	       (bool-vector t)
	       (compat--bool-vector-not
		(bool-vector nil))))
	     (1should
	      (equal
	       (bool-vector nil)
	       (compat--bool-vector-not
		(bool-vector t))))
	     (1should
	      (equal
	       (bool-vector t t)
	       (compat--bool-vector-not
		(bool-vector nil nil))))
	     (1should
	      (equal
	       (bool-vector t nil)
	       (compat--bool-vector-not
		(bool-vector nil t))))
	     (1should
	      (equal
	       (bool-vector nil t)
	       (compat--bool-vector-not
		(bool-vector t nil))))
	     (1should
	      (equal
	       (bool-vector nil nil)
	       (compat--bool-vector-not
		(bool-vector t t))))
	     (expect wrong-type-argument
		     (vector))
	     (expect wrong-type-argument
		     (vector)
		     (vector)))
(ert-deftest compat-ref-bool-vector-subsetp nil "Check if the real `bool-vector-subsetp' works as expected."
	     (1should
	      (equal t
		     (bool-vector-subsetp
		      (bool-vector)
		      (bool-vector))))
	     (1should
	      (equal t
		     (bool-vector-subsetp
		      (bool-vector t)
		      (bool-vector t))))
	     (1should
	      (equal t
		     (bool-vector-subsetp
		      (bool-vector nil)
		      (bool-vector t))))
	     (1should
	      (equal nil
		     (bool-vector-subsetp
		      (bool-vector t)
		      (bool-vector nil))))
	     (1should
	      (equal t
		     (bool-vector-subsetp
		      (bool-vector nil)
		      (bool-vector nil))))
	     (1should
	      (equal t
		     (bool-vector-subsetp
		      (bool-vector t t)
		      (bool-vector t t))))
	     (1should
	      (equal t
		     (bool-vector-subsetp
		      (bool-vector nil nil)
		      (bool-vector t t))))
	     (1should
	      (equal t
		     (bool-vector-subsetp
		      (bool-vector nil nil)
		      (bool-vector t nil))))
	     (1should
	      (equal t
		     (bool-vector-subsetp
		      (bool-vector nil nil)
		      (bool-vector nil t))))
	     (1should
	      (equal nil
		     (bool-vector-subsetp
		      (bool-vector t nil)
		      (bool-vector nil nil))))
	     (1should
	      (equal nil
		     (bool-vector-subsetp
		      (bool-vector nil t)
		      (bool-vector nil nil))))
	     (if
		 (version<= "24.4" emacs-version)
		 (progn
		   (expect wrong-length-argument
			   (bool-vector nil)
			   (bool-vector nil nil))))
	     (expect wrong-type-argument
		     (bool-vector)
		     (vector))
	     (expect wrong-type-argument
		     (vector)
		     (bool-vector))
	     (expect wrong-type-argument
		     (vector)
		     (vector)))
(ert-deftest compat-impl-bool-vector-subsetp nil "Check if compat `bool-vector-subsetp' works as expected."
	     (1should
	      (equal t
		     (compat--bool-vector-subsetp
		      (bool-vector)
		      (bool-vector))))
	     (1should
	      (equal t
		     (compat--bool-vector-subsetp
		      (bool-vector t)
		      (bool-vector t))))
	     (1should
	      (equal t
		     (compat--bool-vector-subsetp
		      (bool-vector nil)
		      (bool-vector t))))
	     (1should
	      (equal nil
		     (compat--bool-vector-subsetp
		      (bool-vector t)
		      (bool-vector nil))))
	     (1should
	      (equal t
		     (compat--bool-vector-subsetp
		      (bool-vector nil)
		      (bool-vector nil))))
	     (1should
	      (equal t
		     (compat--bool-vector-subsetp
		      (bool-vector t t)
		      (bool-vector t t))))
	     (1should
	      (equal t
		     (compat--bool-vector-subsetp
		      (bool-vector nil nil)
		      (bool-vector t t))))
	     (1should
	      (equal t
		     (compat--bool-vector-subsetp
		      (bool-vector nil nil)
		      (bool-vector t nil))))
	     (1should
	      (equal t
		     (compat--bool-vector-subsetp
		      (bool-vector nil nil)
		      (bool-vector nil t))))
	     (1should
	      (equal nil
		     (compat--bool-vector-subsetp
		      (bool-vector t nil)
		      (bool-vector nil nil))))
	     (1should
	      (equal nil
		     (compat--bool-vector-subsetp
		      (bool-vector nil t)
		      (bool-vector nil nil))))
	     (if
		 (version<= "24.4" emacs-version)
		 (progn
		   (expect wrong-length-argument
			   (bool-vector nil)
			   (bool-vector nil nil))))
	     (expect wrong-type-argument
		     (bool-vector)
		     (vector))
	     (expect wrong-type-argument
		     (vector)
		     (bool-vector))
	     (expect wrong-type-argument
		     (vector)
		     (vector)))
(ert-deftest compat-ref-bool-vector-count-consecutive nil "Check if the real `bool-vector-count-consecutive' works as expected."
	     (1should
	      (equal 0
		     (bool-vector-count-consecutive
		      (bool-vector nil)
		      (bool-vector nil)
		      0)))
	     (1should
	      (equal 0
		     (bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      t 0)))
	     (1should
	      (equal 10
		     (bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      nil 0)))
	     (1should
	      (equal 0
		     (bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      t 1)))
	     (1should
	      (equal 9
		     (bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      nil 1)))
	     (1should
	      (equal 0
		     (bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      t 1)))
	     (1should
	      (equal 9
		     (bool-vector-count-consecutive
		      (make-bool-vector 10 t)
		      t 1)))
	     (1should
	      (equal 0
		     (bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      t 8)))
	     (1should
	      (equal 2
		     (bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      nil 8)))
	     (1should
	      (equal 2
		     (bool-vector-count-consecutive
		      (make-bool-vector 10 t)
		      t 8)))
	     (1should
	      (equal 10
		     (bool-vector-count-consecutive
		      (make-bool-vector 10 t)
		      (make-bool-vector 10 t)
		      0)))
	     (1should
	      (equal 4
		     (bool-vector-count-consecutive
		      (bool-vector t t t t nil t t t t t)
		      t 0)))
	     (1should
	      (equal 0
		     (bool-vector-count-consecutive
		      (bool-vector t t t t nil t t t t t)
		      t 4)))
	     (1should
	      (equal 5
		     (bool-vector-count-consecutive
		      (bool-vector t t t t nil t t t t t)
		      t 5)))
	     (expect wrong-type-argument
		     (vector)
		     nil 0))
(ert-deftest compat-impl-bool-vector-count-consecutive nil "Check if compat `bool-vector-count-consecutive' works as expected."
	     (1should
	      (equal 0
		     (compat--bool-vector-count-consecutive
		      (bool-vector nil)
		      (bool-vector nil)
		      0)))
	     (1should
	      (equal 0
		     (compat--bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      t 0)))
	     (1should
	      (equal 10
		     (compat--bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      nil 0)))
	     (1should
	      (equal 0
		     (compat--bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      t 1)))
	     (1should
	      (equal 9
		     (compat--bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      nil 1)))
	     (1should
	      (equal 0
		     (compat--bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      t 1)))
	     (1should
	      (equal 9
		     (compat--bool-vector-count-consecutive
		      (make-bool-vector 10 t)
		      t 1)))
	     (1should
	      (equal 0
		     (compat--bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      t 8)))
	     (1should
	      (equal 2
		     (compat--bool-vector-count-consecutive
		      (make-bool-vector 10 nil)
		      nil 8)))
	     (1should
	      (equal 2
		     (compat--bool-vector-count-consecutive
		      (make-bool-vector 10 t)
		      t 8)))
	     (1should
	      (equal 10
		     (compat--bool-vector-count-consecutive
		      (make-bool-vector 10 t)
		      (make-bool-vector 10 t)
		      0)))
	     (1should
	      (equal 4
		     (compat--bool-vector-count-consecutive
		      (bool-vector t t t t nil t t t t t)
		      t 0)))
	     (1should
	      (equal 0
		     (compat--bool-vector-count-consecutive
		      (bool-vector t t t t nil t t t t t)
		      t 4)))
	     (1should
	      (equal 5
		     (compat--bool-vector-count-consecutive
		      (bool-vector t t t t nil t t t t t)
		      t 5)))
	     (expect wrong-type-argument
		     (vector)
		     nil 0))
(ert-deftest compat-ref-bool-vector-count-population nil "Check if the real `bool-vector-count-population' works as expected."
	     (1should
	      (equal 0
		     (bool-vector-count-population
		      (bool-vector))))
	     (1should
	      (equal 0
		     (bool-vector-count-population
		      (make-bool-vector 10 nil))))
	     (1should
	      (equal 10
		     (bool-vector-count-population
		      (make-bool-vector 10 t))))
	     (1should
	      (equal 1
		     (bool-vector-count-population
		      (bool-vector nil nil t nil))))
	     (1should
	      (equal 1
		     (bool-vector-count-population
		      (bool-vector nil nil nil t))))
	     (1should
	      (equal 1
		     (bool-vector-count-population
		      (bool-vector t nil nil nil))))
	     (1should
	      (equal 2
		     (bool-vector-count-population
		      (bool-vector t nil nil t))))
	     (1should
	      (equal 2
		     (bool-vector-count-population
		      (bool-vector t nil t nil))))
	     (1should
	      (equal 3
		     (bool-vector-count-population
		      (bool-vector t nil t t))))
	     (expect wrong-type-argument
		     (vector)))
(ert-deftest compat-impl-bool-vector-count-population nil "Check if compat `bool-vector-count-population' works as expected."
	     (1should
	      (equal 0
		     (compat--bool-vector-count-population
		      (bool-vector))))
	     (1should
	      (equal 0
		     (compat--bool-vector-count-population
		      (make-bool-vector 10 nil))))
	     (1should
	      (equal 10
		     (compat--bool-vector-count-population
		      (make-bool-vector 10 t))))
	     (1should
	      (equal 1
		     (compat--bool-vector-count-population
		      (bool-vector nil nil t nil))))
	     (1should
	      (equal 1
		     (compat--bool-vector-count-population
		      (bool-vector nil nil nil t))))
	     (1should
	      (equal 1
		     (compat--bool-vector-count-population
		      (bool-vector t nil nil nil))))
	     (1should
	      (equal 2
		     (compat--bool-vector-count-population
		      (bool-vector t nil nil t))))
	     (1should
	      (equal 2
		     (compat--bool-vector-count-population
		      (bool-vector t nil t nil))))
	     (1should
	      (equal 3
		     (compat--bool-vector-count-population
		      (bool-vector t nil t t))))
	     (expect wrong-type-argument
		     (vector)))
(ert-deftest compat-ref-compat-assoc-delete-all nil "Check if the real `compat-assoc-delete-all' works as expected."
	     (1should
	      (equal
	       (list)
	       (compat-assoc-delete-all 0
					(list))))
	     (1should
	      (equal
	       '((1 . one))
	       (compat-assoc-delete-all 0
					(list
					 (cons 1 'one)))))
	     (1should
	      (equal
	       '((1 . one)
		 a)
	       (compat-assoc-delete-all 0
					(list
					 (cons 1 'one)
					 'a))))
	     (1should
	      (equal
	       '((1 . one))
	       (compat-assoc-delete-all 0
					(list
					 (cons 0 'zero)
					 (cons 1 'one)))))
	     (1should
	      (equal
	       '((1 . one))
	       (compat-assoc-delete-all 0
					(list
					 (cons 0 'zero)
					 (cons 0 'zero)
					 (cons 1 'one)))))
	     (1should
	      (equal
	       '((1 . one))
	       (compat-assoc-delete-all 0
					(list
					 (cons 0 'zero)
					 (cons 1 'one)
					 (cons 0 'zero)))))
	     (1should
	      (equal
	       '((1 . one)
		 a)
	       (compat-assoc-delete-all 0
					(list
					 (cons 0 'zero)
					 (cons 1 'one)
					 'a
					 (cons 0 'zero)))))
	     (1should
	      (equal
	       '(a
		 (1 . one))
	       (compat-assoc-delete-all 0
					(list 'a
					      (cons 0 'zero)
					      (cons 1 'one)
					      (cons 0 'zero)))))
	     (1should
	      (equal
	       '(("one" . one))
	       (compat-assoc-delete-all "zero"
					(list
					 (cons "one" 'one)))))
	     (1should
	      (equal
	       '(("one" . one)
		 a)
	       (compat-assoc-delete-all "zero"
					(list
					 (cons "one" 'one)
					 'a))))
	     (1should
	      (equal
	       '(("one" . one))
	       (compat-assoc-delete-all "zero"
					(list
					 (cons "zero" 'zero)
					 (cons "one" 'one)))))
	     (1should
	      (equal
	       '(("one" . one))
	       (compat-assoc-delete-all "zero"
					(list
					 (cons "zero" 'zero)
					 (cons "zero" 'zero)
					 (cons "one" 'one)))))
	     (1should
	      (equal
	       '(("one" . one))
	       (compat-assoc-delete-all "zero"
					(list
					 (cons "zero" 'zero)
					 (cons "one" 'one)
					 (cons "zero" 'zero)))))
	     (1should
	      (equal
	       '(("one" . one)
		 a)
	       (compat-assoc-delete-all "zero"
					(list
					 (cons "zero" 'zero)
					 (cons "one" 'one)
					 'a
					 (cons "zero" 'zero)))))
	     (1should
	      (equal
	       '(a
		 ("one" . one))
	       (compat-assoc-delete-all "zero"
					(list 'a
					      (cons "zero" 'zero)
					      (cons "one" 'one)
					      (cons "zero" 'zero)))))
	     (1should
	      (equal 'nil
		     (compat-assoc-delete-all 0
					      (list
					       (cons 1 'one))
					      #'/=)))
	     (1should
	      (equal
	       '(a)
	       (compat-assoc-delete-all 0
					(list
					 (cons 1 'one)
					 'a)
					#'/=)))
	     (1should
	      (equal
	       '((0 . zero))
	       (compat-assoc-delete-all 0
					(list
					 (cons 0 'zero)
					 (cons 1 'one))
					#'/=)))
	     (1should
	      (equal
	       '((0 . zero)
		 (0 . zero))
	       (compat-assoc-delete-all 0
					(list
					 (cons 0 'zero)
					 (cons 0 'zero)
					 (cons 1 'one))
					#'/=)))
	     (1should
	      (equal
	       '((0 . zero)
		 (0 . zero))
	       (compat-assoc-delete-all 0
					(list
					 (cons 0 'zero)
					 (cons 1 'one)
					 (cons 0 'zero))
					#'/=)))
	     (1should
	      (equal
	       '((0 . zero)
		 a
		 (0 . zero))
	       (compat-assoc-delete-all 0
					(list
					 (cons 0 'zero)
					 (cons 1 'one)
					 'a
					 (cons 0 'zero))
					#'/=)))
	     (1should
	      (equal
	       '(a
		 (0 . zero)
		 (0 . zero))
	       (compat-assoc-delete-all 0
					(list 'a
					      (cons 0 'zero)
					      (cons 1 'one)
					      (cons 0 'zero))
					#'/=))))
(ert-deftest compat-impl-compat-assoc-delete-all nil "Check if compat `compat-assoc-delete-all' works as expected."
	     (1should
	      (equal
	       (list)
	       (compat--compat-assoc-delete-all 0
						(list))))
	     (1should
	      (equal
	       '((1 . one))
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 1 'one)))))
	     (1should
	      (equal
	       '((1 . one)
		 a)
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 1 'one)
						 'a))))
	     (1should
	      (equal
	       '((1 . one))
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 0 'zero)
						 (cons 1 'one)))))
	     (1should
	      (equal
	       '((1 . one))
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 0 'zero)
						 (cons 0 'zero)
						 (cons 1 'one)))))
	     (1should
	      (equal
	       '((1 . one))
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 0 'zero)
						 (cons 1 'one)
						 (cons 0 'zero)))))
	     (1should
	      (equal
	       '((1 . one)
		 a)
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 0 'zero)
						 (cons 1 'one)
						 'a
						 (cons 0 'zero)))))
	     (1should
	      (equal
	       '(a
		 (1 . one))
	       (compat--compat-assoc-delete-all 0
						(list 'a
						      (cons 0 'zero)
						      (cons 1 'one)
						      (cons 0 'zero)))))
	     (1should
	      (equal
	       '(("one" . one))
	       (compat--compat-assoc-delete-all "zero"
						(list
						 (cons "one" 'one)))))
	     (1should
	      (equal
	       '(("one" . one)
		 a)
	       (compat--compat-assoc-delete-all "zero"
						(list
						 (cons "one" 'one)
						 'a))))
	     (1should
	      (equal
	       '(("one" . one))
	       (compat--compat-assoc-delete-all "zero"
						(list
						 (cons "zero" 'zero)
						 (cons "one" 'one)))))
	     (1should
	      (equal
	       '(("one" . one))
	       (compat--compat-assoc-delete-all "zero"
						(list
						 (cons "zero" 'zero)
						 (cons "zero" 'zero)
						 (cons "one" 'one)))))
	     (1should
	      (equal
	       '(("one" . one))
	       (compat--compat-assoc-delete-all "zero"
						(list
						 (cons "zero" 'zero)
						 (cons "one" 'one)
						 (cons "zero" 'zero)))))
	     (1should
	      (equal
	       '(("one" . one)
		 a)
	       (compat--compat-assoc-delete-all "zero"
						(list
						 (cons "zero" 'zero)
						 (cons "one" 'one)
						 'a
						 (cons "zero" 'zero)))))
	     (1should
	      (equal
	       '(a
		 ("one" . one))
	       (compat--compat-assoc-delete-all "zero"
						(list 'a
						      (cons "zero" 'zero)
						      (cons "one" 'one)
						      (cons "zero" 'zero)))))
	     (1should
	      (equal 'nil
		     (compat--compat-assoc-delete-all 0
						      (list
						       (cons 1 'one))
						      #'/=)))
	     (1should
	      (equal
	       '(a)
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 1 'one)
						 'a)
						#'/=)))
	     (1should
	      (equal
	       '((0 . zero))
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 0 'zero)
						 (cons 1 'one))
						#'/=)))
	     (1should
	      (equal
	       '((0 . zero)
		 (0 . zero))
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 0 'zero)
						 (cons 0 'zero)
						 (cons 1 'one))
						#'/=)))
	     (1should
	      (equal
	       '((0 . zero)
		 (0 . zero))
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 0 'zero)
						 (cons 1 'one)
						 (cons 0 'zero))
						#'/=)))
	     (1should
	      (equal
	       '((0 . zero)
		 a
		 (0 . zero))
	       (compat--compat-assoc-delete-all 0
						(list
						 (cons 0 'zero)
						 (cons 1 'one)
						 'a
						 (cons 0 'zero))
						#'/=)))
	     (1should
	      (equal
	       '(a
		 (0 . zero)
		 (0 . zero))
	       (compat--compat-assoc-delete-all 0
						(list 'a
						      (cons 0 'zero)
						      (cons 1 'one)
						      (cons 0 'zero))
						#'/=))))
(ert-deftest compat-ref-color-values-from-color-spec nil "Check if the real `color-values-from-color-spec' works as expected."
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "#000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "#000000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "#000000000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "#000000000000")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (color-values-from-color-spec "#00F")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (color-values-from-color-spec "#0000FF")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (color-values-from-color-spec "#000000FFF")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (color-values-from-color-spec "#00000000FFFF")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (color-values-from-color-spec "#00f")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (color-values-from-color-spec "#0000ff")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (color-values-from-color-spec "#000000fff")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (color-values-from-color-spec "#00000000ffff")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (color-values-from-color-spec "#00000000ffFF")))
	     (1should
	      (equal
	       '(65535 0 21845)
	       (color-values-from-color-spec "#f05")))
	     (1should
	      (equal
	       '(7967 45232 50629)
	       (color-values-from-color-spec "#1fb0C5")))
	     (1should
	      (equal
	       '(8067 45229 50658)
	       (color-values-from-color-spec "#1f83b0ADC5e2")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#00")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#0000FG")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#0000FFF")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#0000FFFF")))
	     (1should
	      (equal
	       '(0 4080 65535)
	       (color-values-from-color-spec "#0000FFFFF")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#000FF")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#0000F")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec " #000000")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#000000 ")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec " #000000 ")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#1f83b0ADC5e2g")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#1f83b0ADC5e20")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "#12345")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgb:0/0/0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgb:0/0/00")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgb:0/00/000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgb:0/000/0000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgb:000/0000/0")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (color-values-from-color-spec "rgb:000/0000/F")))
	     (1should
	      (equal
	       '(65535 0 65535)
	       (color-values-from-color-spec "rgb:FFF/0000/F")))
	     (1should
	      (equal
	       '(65535 0 65535)
	       (color-values-from-color-spec "rgb:FFFF/0000/FFFF")))
	     (1should
	      (equal
	       '(0 255 65535)
	       (color-values-from-color-spec "rgb:0/00FF/FFFF")))
	     (1should
	      (equal
	       '(65535 8995 10402)
	       (color-values-from-color-spec "rgb:f/23/28a")))
	     (1should
	      (equal
	       '(4660 22136 2475)
	       (color-values-from-color-spec "rgb:1234/5678/09ab")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgb:/0000/FFFF")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgb:0000/0000/FFFG")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgb:0000/0000/FFFFF")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgb:0000/0000")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rg:0000/0000/0000")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgb: 0000/0000/0000")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbb:0000/0000/0000")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgb:0000/0000/0000   ")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec " rgb:0000/0000/0000  ")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "  rgb:0000/0000/0000")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgb:0000/ 0000 /0000")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgb: 0000 /0000 /0000")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgb:0//0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgbi:0/0/0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgbi:0.0/0.0/0.0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgbi:0.0/0/0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgbi:0.0/0/0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgbi:0/0/0.")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgbi:0/0/0.0000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgbi:0/0/.0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (color-values-from-color-spec "rgbi:0/0/.0000")))
	     (1should
	      (equal
	       '(65535 0 0)
	       (color-values-from-color-spec "rgbi:1/0/0.0000")))
	     (1should
	      (equal
	       '(65535 0 0)
	       (color-values-from-color-spec "rgbi:1./0/0.0000")))
	     (1should
	      (equal
	       '(65535 0 0)
	       (color-values-from-color-spec "rgbi:1.0/0/0.0000")))
	     (1should
	      (equal
	       '(65535 32768 0)
	       (color-values-from-color-spec "rgbi:1.0/0.5/0.0000")))
	     (1should
	      (equal
	       '(6554 21843 65469)
	       (color-values-from-color-spec "rgbi:0.1/0.3333/0.999")))
	     (1should
	      (equal
	       '(0 32768 6554)
	       (color-values-from-color-spec "rgbi:0/0.5/0.1")))
	     (1should
	      (equal
	       '(66 655 65535)
	       (color-values-from-color-spec "rgbi:1e-3/1.0e-2/1e0")))
	     (1should
	      (equal
	       '(6554 21843 65469)
	       (color-values-from-color-spec "rgbi:1e-1/+0.3333/0.00999e2")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi:1.0001/0/0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi:2/0/0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi:0.a/0/0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi:./0/0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi:./0/0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec " rgbi:0/0/0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi:0/0/0 ")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "	rgbi:0/0/0 ")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi:0 /0/ 0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi:0/ 0 /0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbii:0/0/0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi :0/0/0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi : 0/0/0")))
	     (1should
	      (equal nil
		     (color-values-from-color-spec "rgbi:0/0.5/10"))))
(ert-deftest compat-impl-color-values-from-color-spec nil "Check if compat `color-values-from-color-spec' works as expected."
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "#000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "#000000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "#000000000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "#000000000000")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (compat--color-values-from-color-spec "#00F")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (compat--color-values-from-color-spec "#0000FF")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (compat--color-values-from-color-spec "#000000FFF")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (compat--color-values-from-color-spec "#00000000FFFF")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (compat--color-values-from-color-spec "#00f")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (compat--color-values-from-color-spec "#0000ff")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (compat--color-values-from-color-spec "#000000fff")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (compat--color-values-from-color-spec "#00000000ffff")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (compat--color-values-from-color-spec "#00000000ffFF")))
	     (1should
	      (equal
	       '(65535 0 21845)
	       (compat--color-values-from-color-spec "#f05")))
	     (1should
	      (equal
	       '(7967 45232 50629)
	       (compat--color-values-from-color-spec "#1fb0C5")))
	     (1should
	      (equal
	       '(8067 45229 50658)
	       (compat--color-values-from-color-spec "#1f83b0ADC5e2")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#00")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#0000FG")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#0000FFF")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#0000FFFF")))
	     (1should
	      (equal
	       '(0 4080 65535)
	       (compat--color-values-from-color-spec "#0000FFFFF")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#000FF")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#0000F")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec " #000000")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#000000 ")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec " #000000 ")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#1f83b0ADC5e2g")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#1f83b0ADC5e20")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "#12345")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgb:0/0/0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgb:0/0/00")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgb:0/00/000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgb:0/000/0000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgb:000/0000/0")))
	     (1should
	      (equal
	       '(0 0 65535)
	       (compat--color-values-from-color-spec "rgb:000/0000/F")))
	     (1should
	      (equal
	       '(65535 0 65535)
	       (compat--color-values-from-color-spec "rgb:FFF/0000/F")))
	     (1should
	      (equal
	       '(65535 0 65535)
	       (compat--color-values-from-color-spec "rgb:FFFF/0000/FFFF")))
	     (1should
	      (equal
	       '(0 255 65535)
	       (compat--color-values-from-color-spec "rgb:0/00FF/FFFF")))
	     (1should
	      (equal
	       '(65535 8995 10402)
	       (compat--color-values-from-color-spec "rgb:f/23/28a")))
	     (1should
	      (equal
	       '(4660 22136 2475)
	       (compat--color-values-from-color-spec "rgb:1234/5678/09ab")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgb:/0000/FFFF")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgb:0000/0000/FFFG")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgb:0000/0000/FFFFF")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgb:0000/0000")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rg:0000/0000/0000")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgb: 0000/0000/0000")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbb:0000/0000/0000")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgb:0000/0000/0000   ")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec " rgb:0000/0000/0000  ")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "  rgb:0000/0000/0000")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgb:0000/ 0000 /0000")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgb: 0000 /0000 /0000")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgb:0//0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgbi:0/0/0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgbi:0.0/0.0/0.0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgbi:0.0/0/0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgbi:0.0/0/0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgbi:0/0/0.")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgbi:0/0/0.0000")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgbi:0/0/.0")))
	     (1should
	      (equal
	       '(0 0 0)
	       (compat--color-values-from-color-spec "rgbi:0/0/.0000")))
	     (1should
	      (equal
	       '(65535 0 0)
	       (compat--color-values-from-color-spec "rgbi:1/0/0.0000")))
	     (1should
	      (equal
	       '(65535 0 0)
	       (compat--color-values-from-color-spec "rgbi:1./0/0.0000")))
	     (1should
	      (equal
	       '(65535 0 0)
	       (compat--color-values-from-color-spec "rgbi:1.0/0/0.0000")))
	     (1should
	      (equal
	       '(65535 32768 0)
	       (compat--color-values-from-color-spec "rgbi:1.0/0.5/0.0000")))
	     (1should
	      (equal
	       '(6554 21843 65469)
	       (compat--color-values-from-color-spec "rgbi:0.1/0.3333/0.999")))
	     (1should
	      (equal
	       '(0 32768 6554)
	       (compat--color-values-from-color-spec "rgbi:0/0.5/0.1")))
	     (1should
	      (equal
	       '(66 655 65535)
	       (compat--color-values-from-color-spec "rgbi:1e-3/1.0e-2/1e0")))
	     (1should
	      (equal
	       '(6554 21843 65469)
	       (compat--color-values-from-color-spec "rgbi:1e-1/+0.3333/0.00999e2")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi:1.0001/0/0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi:2/0/0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi:0.a/0/0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi:./0/0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi:./0/0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec " rgbi:0/0/0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi:0/0/0 ")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "	rgbi:0/0/0 ")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi:0 /0/ 0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi:0/ 0 /0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbii:0/0/0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi :0/0/0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi : 0/0/0")))
	     (1should
	      (equal nil
		     (compat--color-values-from-color-spec "rgbi:0/0.5/10"))))
(ert-deftest compat-ref-file-modes-number-to-symbolic nil "Check if the real `file-modes-number-to-symbolic' works as expected."
	     (1should
	      (equal "-rwx------"
		     (file-modes-number-to-symbolic 448)))
	     (1should
	      (equal "-rwxrwx---"
		     (file-modes-number-to-symbolic 504)))
	     (1should
	      (equal "-rwx---rwx"
		     (file-modes-number-to-symbolic 455)))
	     (1should
	      (equal "-rw-r-xr--"
		     (file-modes-number-to-symbolic 428)))
	     (1should
	      (equal "--wx-w---x"
		     (file-modes-number-to-symbolic 209)))
	     (1should
	      (equal "drwx------"
		     (file-modes-number-to-symbolic 448 100)))
	     (1should
	      (equal "?rwx------"
		     (file-modes-number-to-symbolic 448 63)))
	     (1should
	      (equal "lrwx------"
		     (file-modes-number-to-symbolic 41408)))
	     (1should
	      (equal "prwx------"
		     (file-modes-number-to-symbolic 4544)))
	     (1should
	      (equal "-rwx------"
		     (file-modes-number-to-symbolic 12736))))
(ert-deftest compat-impl-file-modes-number-to-symbolic nil "Check if compat `file-modes-number-to-symbolic' works as expected."
	     (1should
	      (equal "-rwx------"
		     (compat--file-modes-number-to-symbolic 448)))
	     (1should
	      (equal "-rwxrwx---"
		     (compat--file-modes-number-to-symbolic 504)))
	     (1should
	      (equal "-rwx---rwx"
		     (compat--file-modes-number-to-symbolic 455)))
	     (1should
	      (equal "-rw-r-xr--"
		     (compat--file-modes-number-to-symbolic 428)))
	     (1should
	      (equal "--wx-w---x"
		     (compat--file-modes-number-to-symbolic 209)))
	     (1should
	      (equal "drwx------"
		     (compat--file-modes-number-to-symbolic 448 100)))
	     (1should
	      (equal "?rwx------"
		     (compat--file-modes-number-to-symbolic 448 63)))
	     (1should
	      (equal "lrwx------"
		     (compat--file-modes-number-to-symbolic 41408)))
	     (1should
	      (equal "prwx------"
		     (compat--file-modes-number-to-symbolic 4544)))
	     (1should
	      (equal "-rwx------"
		     (compat--file-modes-number-to-symbolic 12736))))
(ert-deftest compat-ref-file-local-name nil "Check if the real `file-local-name' works as expected."
	     (1should
	      (equal ""
		     (file-local-name "")))
	     (1should
	      (equal "foo"
		     (file-local-name "foo")))
	     (1should
	      (equal "/bar/foo"
		     (file-local-name "/bar/foo")))
	     (1should
	      (equal "foo"
		     (file-local-name "/ssh::foo")))
	     (1should
	      (equal "/bar/foo"
		     (file-local-name "/ssh::/bar/foo")))
	     (1should
	      (equal ":foo"
		     (file-local-name "/ssh:::foo")))
	     (1should
	      (equal ":/bar/foo"
		     (file-local-name "/ssh:::/bar/foo"))))
(ert-deftest compat-impl-file-local-name nil "Check if compat `file-local-name' works as expected."
	     (1should
	      (equal ""
		     (compat--file-local-name "")))
	     (1should
	      (equal "foo"
		     (compat--file-local-name "foo")))
	     (1should
	      (equal "/bar/foo"
		     (compat--file-local-name "/bar/foo")))
	     (1should
	      (equal "foo"
		     (compat--file-local-name "/ssh::foo")))
	     (1should
	      (equal "/bar/foo"
		     (compat--file-local-name "/ssh::/bar/foo")))
	     (1should
	      (equal ":foo"
		     (compat--file-local-name "/ssh:::foo")))
	     (1should
	      (equal ":/bar/foo"
		     (compat--file-local-name "/ssh:::/bar/foo"))))
(ert-deftest compat-ref-file-name-quoted-p nil "Check if the real `file-name-quoted-p' works as expected."
	     (1should
	      (equal nil
		     (file-name-quoted-p "")))
	     (1should
	      (equal t
		     (file-name-quoted-p "/:")))
	     (1should
	      (equal nil
		     (file-name-quoted-p "//:")))
	     (1should
	      (equal t
		     (file-name-quoted-p "/::")))
	     (1should
	      (equal nil
		     (file-name-quoted-p "/ssh::")))
	     (1should
	      (equal nil
		     (file-name-quoted-p "/ssh::a")))
	     (1should
	      (equal t
		     (file-name-quoted-p "/ssh::/:a"))))
(ert-deftest compat-impl-file-name-quoted-p nil "Check if compat `file-name-quoted-p' works as expected."
	     (1should
	      (equal nil
		     (compat--file-name-quoted-p "")))
	     (1should
	      (equal t
		     (compat--file-name-quoted-p "/:")))
	     (1should
	      (equal nil
		     (compat--file-name-quoted-p "//:")))
	     (1should
	      (equal t
		     (compat--file-name-quoted-p "/::")))
	     (1should
	      (equal nil
		     (compat--file-name-quoted-p "/ssh::")))
	     (1should
	      (equal nil
		     (compat--file-name-quoted-p "/ssh::a")))
	     (1should
	      (equal t
		     (compat--file-name-quoted-p "/ssh::/:a"))))
(ert-deftest compat-ref-file-name-quote nil "Check if the real `file-name-quote' works as expected."
	     (1should
	      (equal "/:"
		     (file-name-quote "")))
	     (1should
	      (equal "/::"
		     (file-name-quote ":")))
	     (1should
	      (equal "/:/"
		     (file-name-quote "/")))
	     (1should
	      (equal "/:"
		     (file-name-quote "/:")))
	     (1should
	      (equal "/:a"
		     (file-name-quote "a")))
	     (1should
	      (equal "/::a"
		     (file-name-quote ":a")))
	     (1should
	      (equal "/:/a"
		     (file-name-quote "/a")))
	     (1should
	      (equal "/:a"
		     (file-name-quote "/:a")))
	     (1should
	      (equal
	       (concat "/ssh:"
		       (system-name)
		       ":/:a")
	       (file-name-quote "/ssh::a"))))
(ert-deftest compat-impl-file-name-quote nil "Check if compat `file-name-quote' works as expected."
	     (1should
	      (equal "/:"
		     (compat--file-name-quote "")))
	     (1should
	      (equal "/::"
		     (compat--file-name-quote ":")))
	     (1should
	      (equal "/:/"
		     (compat--file-name-quote "/")))
	     (1should
	      (equal "/:"
		     (compat--file-name-quote "/:")))
	     (1should
	      (equal "/:a"
		     (compat--file-name-quote "a")))
	     (1should
	      (equal "/::a"
		     (compat--file-name-quote ":a")))
	     (1should
	      (equal "/:/a"
		     (compat--file-name-quote "/a")))
	     (1should
	      (equal "/:a"
		     (compat--file-name-quote "/:a")))
	     (1should
	      (equal
	       (concat "/ssh:"
		       (system-name)
		       ":/:a")
	       (compat--file-name-quote "/ssh::a"))))
(ert-deftest compat-ref-make-lock-file-name nil "Check if the real `make-lock-file-name' works as expected."
	     (1should
	      (equal
	       (expand-file-name ".#")
	       (make-lock-file-name "")))
	     (1should
	      (equal
	       (expand-file-name ".#a")
	       (make-lock-file-name "a")))
	     (1should
	      (equal
	       (expand-file-name ".#foo")
	       (make-lock-file-name "foo")))
	     (1should
	      (equal
	       (expand-file-name ".#.")
	       (make-lock-file-name ".")))
	     (1should
	      (equal
	       (expand-file-name ".#.#")
	       (make-lock-file-name ".#")))
	     (1should
	      (equal
	       (expand-file-name ".#.a")
	       (make-lock-file-name ".a")))
	     (1should
	      (equal
	       (expand-file-name ".#.#")
	       (make-lock-file-name ".#")))
	     (1should
	      (equal
	       (expand-file-name "a/.#")
	       (make-lock-file-name "a/")))
	     (1should
	      (equal
	       (expand-file-name "a/.#b")
	       (make-lock-file-name "a/b")))
	     (1should
	      (equal
	       (expand-file-name "a/.#.#")
	       (make-lock-file-name "a/.#")))
	     (1should
	      (equal
	       (expand-file-name "a/.#.")
	       (make-lock-file-name "a/.")))
	     (1should
	      (equal
	       (expand-file-name "a/.#.b")
	       (make-lock-file-name "a/.b")))
	     (1should
	      (equal
	       (expand-file-name "a/.#foo")
	       (make-lock-file-name "a/foo")))
	     (1should
	      (equal
	       (expand-file-name "bar/.#b")
	       (make-lock-file-name "bar/b")))
	     (1should
	      (equal
	       (expand-file-name "bar/.#foo")
	       (make-lock-file-name "bar/foo"))))
(ert-deftest compat-impl-make-lock-file-name nil "Check if compat `make-lock-file-name' works as expected."
	     (1should
	      (equal
	       (expand-file-name ".#")
	       (compat--make-lock-file-name "")))
	     (1should
	      (equal
	       (expand-file-name ".#a")
	       (compat--make-lock-file-name "a")))
	     (1should
	      (equal
	       (expand-file-name ".#foo")
	       (compat--make-lock-file-name "foo")))
	     (1should
	      (equal
	       (expand-file-name ".#.")
	       (compat--make-lock-file-name ".")))
	     (1should
	      (equal
	       (expand-file-name ".#.#")
	       (compat--make-lock-file-name ".#")))
	     (1should
	      (equal
	       (expand-file-name ".#.a")
	       (compat--make-lock-file-name ".a")))
	     (1should
	      (equal
	       (expand-file-name ".#.#")
	       (compat--make-lock-file-name ".#")))
	     (1should
	      (equal
	       (expand-file-name "a/.#")
	       (compat--make-lock-file-name "a/")))
	     (1should
	      (equal
	       (expand-file-name "a/.#b")
	       (compat--make-lock-file-name "a/b")))
	     (1should
	      (equal
	       (expand-file-name "a/.#.#")
	       (compat--make-lock-file-name "a/.#")))
	     (1should
	      (equal
	       (expand-file-name "a/.#.")
	       (compat--make-lock-file-name "a/.")))
	     (1should
	      (equal
	       (expand-file-name "a/.#.b")
	       (compat--make-lock-file-name "a/.b")))
	     (1should
	      (equal
	       (expand-file-name "a/.#foo")
	       (compat--make-lock-file-name "a/foo")))
	     (1should
	      (equal
	       (expand-file-name "bar/.#b")
	       (compat--make-lock-file-name "bar/b")))
	     (1should
	      (equal
	       (expand-file-name "bar/.#foo")
	       (compat--make-lock-file-name "bar/foo"))))
(ert-deftest compat-ref-time-equal-p nil "Check if the real `time-equal-p' works as expected."
	     (1should
	      (equal t
		     (time-equal-p nil nil)))
	     (1should
	      (equal nil
		     (time-equal-p
		      (current-time)
		      (ignore
		       (sleep-for 0.01)))))
	     (1should
	      (equal nil
		     (time-equal-p
		      (current-time)
		      (progn
			(sleep-for 0.01)
			(current-time)))))
	     (1should
	      (equal t
		     (time-equal-p
		      '(1 2 3 4)
		      '(1 2 3 4))))
	     (1should
	      (equal nil
		     (time-equal-p
		      '(1 2 3 4)
		      '(1 2 3 5))))
	     (1should
	      (equal nil
		     (time-equal-p
		      '(1 2 3 5)
		      '(1 2 3 4))))
	     (1should
	      (equal nil
		     (time-equal-p
		      '(1 2 3 4)
		      '(1 2 4 4))))
	     (1should
	      (equal nil
		     (time-equal-p
		      '(1 2 4 4)
		      '(1 2 3 4))))
	     (1should
	      (equal nil
		     (time-equal-p
		      '(1 2 3 4)
		      '(1 3 3 4))))
	     (1should
	      (equal nil
		     (time-equal-p
		      '(1 3 3 4)
		      '(1 2 3 4))))
	     (1should
	      (equal nil
		     (time-equal-p
		      '(1 2 3 4)
		      '(2 2 3 4))))
	     (1should
	      (equal nil
		     (time-equal-p
		      '(2 2 3 4)
		      '(1 2 3 4)))))
(ert-deftest compat-impl-time-equal-p nil "Check if compat `time-equal-p' works as expected."
	     (1should
	      (equal t
		     (compat--time-equal-p nil nil)))
	     (1should
	      (equal nil
		     (compat--time-equal-p
		      (current-time)
		      (ignore
		       (sleep-for 0.01)))))
	     (1should
	      (equal nil
		     (compat--time-equal-p
		      (current-time)
		      (progn
			(sleep-for 0.01)
			(current-time)))))
	     (1should
	      (equal t
		     (compat--time-equal-p
		      '(1 2 3 4)
		      '(1 2 3 4))))
	     (1should
	      (equal nil
		     (compat--time-equal-p
		      '(1 2 3 4)
		      '(1 2 3 5))))
	     (1should
	      (equal nil
		     (compat--time-equal-p
		      '(1 2 3 5)
		      '(1 2 3 4))))
	     (1should
	      (equal nil
		     (compat--time-equal-p
		      '(1 2 3 4)
		      '(1 2 4 4))))
	     (1should
	      (equal nil
		     (compat--time-equal-p
		      '(1 2 4 4)
		      '(1 2 3 4))))
	     (1should
	      (equal nil
		     (compat--time-equal-p
		      '(1 2 3 4)
		      '(1 3 3 4))))
	     (1should
	      (equal nil
		     (compat--time-equal-p
		      '(1 3 3 4)
		      '(1 2 3 4))))
	     (1should
	      (equal nil
		     (compat--time-equal-p
		      '(1 2 3 4)
		      '(2 2 3 4))))
	     (1should
	      (equal nil
		     (compat--time-equal-p
		      '(2 2 3 4)
		      '(1 2 3 4)))))
(ert-deftest compat-ref-date-days-in-month nil "Check if the real `date-days-in-month' works as expected."
	     (1should
	      (equal 31
		     (date-days-in-month 2020 1)))
	     (1should
	      (equal 30
		     (date-days-in-month 2020 4)))
	     (1should
	      (equal 29
		     (date-days-in-month 2020 2)))
	     (1should
	      (equal 28
		     (date-days-in-month 2021 2))))
(ert-deftest compat-impl-date-days-in-month nil "Check if compat `date-days-in-month' works as expected."
	     (1should
	      (equal 31
		     (compat--date-days-in-month 2020 1)))
	     (1should
	      (equal 30
		     (compat--date-days-in-month 2020 4)))
	     (1should
	      (equal 29
		     (compat--date-days-in-month 2020 2)))
	     (1should
	      (equal 28
		     (compat--date-days-in-month 2021 2))))
(ert-deftest compat-ref-decoded-time-period nil "Check if the real `decoded-time-period' works as expected."
	     (1should
	      (equal 0
		     (decoded-time-period 'nil)))
	     (1should
	      (equal 0
		     (decoded-time-period
		      '(0))))
	     (1should
	      (equal 1
		     (decoded-time-period
		      '(1))))
	     (1should
	      (equal 0.125
		     (decoded-time-period
		      '((1 . 8)))))
	     (1should
	      (equal 60
		     (decoded-time-period
		      '(0 1))))
	     (1should
	      (equal 61
		     (decoded-time-period
		      '(1 1))))
	     (1should
	      (equal -59
		     (decoded-time-period
		      '(1 -1))))
	     (1should
	      (equal
	       (* 60 60)
	       (decoded-time-period
		'(0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60)
		60)
	       (decoded-time-period
		'(0 1 1))))
	     (1should
	      (equal
	       (+
		(* 60 60)
		120 1)
	       (decoded-time-period
		'(1 2 1))))
	     (1should
	      (equal
	       (* 60 60 24)
	       (decoded-time-period
		'(0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24)
		1)
	       (decoded-time-period
		'(1 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24)
		(* 60 60)
		60 1)
	       (decoded-time-period
		'(1 1 1 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24)
		(* 60 60)
		120 1)
	       (decoded-time-period
		'(1 2 1 1))))
	     (1should
	      (equal
	       (* 60 60 24 30)
	       (decoded-time-period
		'(0 0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 30)
		1)
	       (decoded-time-period
		'(1 0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 30)
		60 1)
	       (decoded-time-period
		'(1 1 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 30)
		(* 60 60)
		60 1)
	       (decoded-time-period
		'(1 1 1 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 30)
		(* 60 60 24)
		(* 60 60)
		120 1)
	       (decoded-time-period
		'(1 2 1 1 1))))
	     (1should
	      (equal
	       (* 60 60 24 365)
	       (decoded-time-period
		'(0 0 0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 365)
		1)
	       (decoded-time-period
		'(1 0 0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 365)
		60 1)
	       (decoded-time-period
		'(1 1 0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 365)
		(* 60 60)
		60 1)
	       (decoded-time-period
		'(1 1 1 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 365)
		(* 60 60 24)
		(* 60 60)
		60 1)
	       (decoded-time-period
		'(1 1 1 1 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 365)
		(* 60 60 24 30)
		(* 60 60 24)
		(* 60 60)
		120 1)
	       (decoded-time-period
		'(1 2 1 1 1 1))))
	     (expect wrong-type-argument 'a)
	     (expect wrong-type-argument
		     '(0 a))
	     (expect wrong-type-argument
		     '(0 0 a))
	     (expect wrong-type-argument
		     '(0 0 0 a))
	     (expect wrong-type-argument
		     '(0 0 0 0 a))
	     (expect wrong-type-argument
		     '(0 0 0 0 0 a)))
(ert-deftest compat-impl-decoded-time-period nil "Check if compat `decoded-time-period' works as expected."
	     (1should
	      (equal 0
		     (compat--decoded-time-period 'nil)))
	     (1should
	      (equal 0
		     (compat--decoded-time-period
		      '(0))))
	     (1should
	      (equal 1
		     (compat--decoded-time-period
		      '(1))))
	     (1should
	      (equal 0.125
		     (compat--decoded-time-period
		      '((1 . 8)))))
	     (1should
	      (equal 60
		     (compat--decoded-time-period
		      '(0 1))))
	     (1should
	      (equal 61
		     (compat--decoded-time-period
		      '(1 1))))
	     (1should
	      (equal -59
		     (compat--decoded-time-period
		      '(1 -1))))
	     (1should
	      (equal
	       (* 60 60)
	       (compat--decoded-time-period
		'(0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60)
		60)
	       (compat--decoded-time-period
		'(0 1 1))))
	     (1should
	      (equal
	       (+
		(* 60 60)
		120 1)
	       (compat--decoded-time-period
		'(1 2 1))))
	     (1should
	      (equal
	       (* 60 60 24)
	       (compat--decoded-time-period
		'(0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24)
		1)
	       (compat--decoded-time-period
		'(1 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24)
		(* 60 60)
		60 1)
	       (compat--decoded-time-period
		'(1 1 1 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24)
		(* 60 60)
		120 1)
	       (compat--decoded-time-period
		'(1 2 1 1))))
	     (1should
	      (equal
	       (* 60 60 24 30)
	       (compat--decoded-time-period
		'(0 0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 30)
		1)
	       (compat--decoded-time-period
		'(1 0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 30)
		60 1)
	       (compat--decoded-time-period
		'(1 1 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 30)
		(* 60 60)
		60 1)
	       (compat--decoded-time-period
		'(1 1 1 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 30)
		(* 60 60 24)
		(* 60 60)
		120 1)
	       (compat--decoded-time-period
		'(1 2 1 1 1))))
	     (1should
	      (equal
	       (* 60 60 24 365)
	       (compat--decoded-time-period
		'(0 0 0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 365)
		1)
	       (compat--decoded-time-period
		'(1 0 0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 365)
		60 1)
	       (compat--decoded-time-period
		'(1 1 0 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 365)
		(* 60 60)
		60 1)
	       (compat--decoded-time-period
		'(1 1 1 0 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 365)
		(* 60 60 24)
		(* 60 60)
		60 1)
	       (compat--decoded-time-period
		'(1 1 1 1 0 1))))
	     (1should
	      (equal
	       (+
		(* 60 60 24 365)
		(* 60 60 24 30)
		(* 60 60 24)
		(* 60 60)
		120 1)
	       (compat--decoded-time-period
		'(1 2 1 1 1 1))))
	     (expect wrong-type-argument 'a)
	     (expect wrong-type-argument
		     '(0 a))
	     (expect wrong-type-argument
		     '(0 0 a))
	     (expect wrong-type-argument
		     '(0 0 0 a))
	     (expect wrong-type-argument
		     '(0 0 0 0 a))
	     (expect wrong-type-argument
		     '(0 0 0 0 0 a)))
(ert-deftest compat-ref-subr-primitive-p nil "Check if the real `subr-primitive-p' works as expected."
	     (1should
	      (equal t
		     (subr-primitive-p
		      (symbol-function 'identity))))
	     (if
		 (fboundp 'subr-native-elisp-p)
		 nil
	       (1should
		(equal nil
		       (subr-primitive-p
			(symbol-function 'match-string)))))
	     (1should
	      (equal nil
		     (subr-primitive-p
		      (symbol-function 'defun))))
	     (1should
	      (equal nil
		     (subr-primitive-p nil))))
(ert-deftest compat-impl-subr-primitive-p nil "Check if compat `subr-primitive-p' works as expected."
	     (1should
	      (equal t
		     (compat--subr-primitive-p
		      (symbol-function 'identity))))
	     (if
		 (fboundp 'subr-native-elisp-p)
		 nil
	       (1should
		(equal nil
		       (compat--subr-primitive-p
			(symbol-function 'match-string)))))
	     (1should
	      (equal nil
		     (compat--subr-primitive-p
		      (symbol-function 'defun))))
	     (1should
	      (equal nil
		     (compat--subr-primitive-p nil))))
(ert-deftest compat-ref-take nil "Check if the real `take' works as expected."
	     (1should
	      (equal nil
		     (take 0 nil)))
	     (1should
	      (equal nil
		     (take 0
			   (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1)
	       (take 1
		     (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1 2 3 4 5)
	       (take 5
		     (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1 2 3 4 5)
	       (take 6
		     (list 1 2 3 4 5))))
	     (1should
	      (equal nil
		     (take -1 nil)))
	     (1should
	      (equal nil
		     (take -1
			   (list 1 2 3 4 5)))))
(ert-deftest compat-impl-take nil "Check if compat `take' works as expected."
	     (1should
	      (equal nil
		     (compat--take 0 nil)))
	     (1should
	      (equal nil
		     (compat--take 0
				   (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1)
	       (compat--take 1
			     (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1 2 3 4 5)
	       (compat--take 5
			     (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1 2 3 4 5)
	       (compat--take 6
			     (list 1 2 3 4 5))))
	     (1should
	      (equal nil
		     (compat--take -1 nil)))
	     (1should
	      (equal nil
		     (compat--take -1
				   (list 1 2 3 4 5)))))
(ert-deftest compat-ref-ntake nil "Check if the real `ntake' works as expected."
	     (1should
	      (equal nil
		     (ntake 0 nil)))
	     (1should
	      (equal nil
		     (ntake 0
			    (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1)
	       (ntake 1
		      (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1 2 3 4 5)
	       (ntake 5
		      (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1 2 3 4 5)
	       (ntake 6
		      (list 1 2 3 4 5))))
	     (1should
	      (equal nil
		     (ntake -1 nil)))
	     (1should
	      (equal nil
		     (ntake -1
			    (list 1 2 3 4 5)))))
(ert-deftest compat-impl-ntake nil "Check if compat `ntake' works as expected."
	     (1should
	      (equal nil
		     (compat--ntake 0 nil)))
	     (1should
	      (equal nil
		     (compat--ntake 0
				    (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1)
	       (compat--ntake 1
			      (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1 2 3 4 5)
	       (compat--ntake 5
			      (list 1 2 3 4 5))))
	     (1should
	      (equal
	       (list 1 2 3 4 5)
	       (compat--ntake 6
			      (list 1 2 3 4 5))))
	     (1should
	      (equal nil
		     (compat--ntake -1 nil)))
	     (1should
	      (equal nil
		     (compat--ntake -1
				    (list 1 2 3 4 5)))))
(ert-deftest compat-ref-string-limit nil "Check if the real `string-limit' works as expected."
	     (1should
	      (equal ""
		     (string-limit "" 0)))
	     (1should
	      (equal ""
		     (string-limit "" 1)))
	     (1should
	      (equal ""
		     (string-limit "" 100)))
	     (1should
	      (equal ""
		     (string-limit "1234567890" 0)))
	     (1should
	      (equal "1"
		     (string-limit "1234567890" 1)))
	     (1should
	      (equal "12"
		     (string-limit "1234567890" 2)))
	     (1should
	      (equal "123456789"
		     (string-limit "1234567890" 9)))
	     (1should
	      (equal "1234567890"
		     (string-limit "1234567890" 10)))
	     (1should
	      (equal "1234567890"
		     (string-limit "1234567890" 11)))
	     (1should
	      (equal "1234567890"
		     (string-limit "1234567890" 20)))
	     (1should
	      (equal "a"
		     (string-limit "a𐾘z" 1)))
	     (1should
	      (equal "a𐾘"
		     (string-limit "a𐾘z" 2)))
	     (1should
	      (equal "a𐾘z"
		     (string-limit "a𐾘z" 3)))
	     (1should
	      (equal "a𐾘z"
		     (string-limit "a𐾘z" 4)))
	     (1should
	      (equal
	       []
	       (string-limit
		[1 2 3]
		0)))
	     (1should
	      (equal
	       [1]
	       (string-limit
		[1 2 3]
		1)))
	     (1should
	      (equal
	       [1 2]
	       (string-limit
		[1 2 3]
		2)))
	     (1should
	      (equal
	       [1 2 3]
	       (string-limit
		[1 2 3]
		3)))
	     (1should
	      (equal
	       [1 2 3]
	       (string-limit
		[1 2 3]
		4)))
	     (expect wrong-type-argument "abc" -1)
	     (expect wrong-type-argument "abc" 'a)
	     (expect wrong-type-argument 'a 2)
	     (expect wrong-type-argument 'a 'b))
(ert-deftest compat-impl-string-limit nil "Check if compat `string-limit' works as expected."
	     (1should
	      (equal ""
		     (compat--string-limit "" 0)))
	     (1should
	      (equal ""
		     (compat--string-limit "" 1)))
	     (1should
	      (equal ""
		     (compat--string-limit "" 100)))
	     (1should
	      (equal ""
		     (compat--string-limit "1234567890" 0)))
	     (1should
	      (equal "1"
		     (compat--string-limit "1234567890" 1)))
	     (1should
	      (equal "12"
		     (compat--string-limit "1234567890" 2)))
	     (1should
	      (equal "123456789"
		     (compat--string-limit "1234567890" 9)))
	     (1should
	      (equal "1234567890"
		     (compat--string-limit "1234567890" 10)))
	     (1should
	      (equal "1234567890"
		     (compat--string-limit "1234567890" 11)))
	     (1should
	      (equal "1234567890"
		     (compat--string-limit "1234567890" 20)))
	     (1should
	      (equal "a"
		     (compat--string-limit "a𐾘z" 1)))
	     (1should
	      (equal "a𐾘"
		     (compat--string-limit "a𐾘z" 2)))
	     (1should
	      (equal "a𐾘z"
		     (compat--string-limit "a𐾘z" 3)))
	     (1should
	      (equal "a𐾘z"
		     (compat--string-limit "a𐾘z" 4)))
	     (1should
	      (equal
	       []
	       (compat--string-limit
		[1 2 3]
		0)))
	     (1should
	      (equal
	       [1]
	       (compat--string-limit
		[1 2 3]
		1)))
	     (1should
	      (equal
	       [1 2]
	       (compat--string-limit
		[1 2 3]
		2)))
	     (1should
	      (equal
	       [1 2 3]
	       (compat--string-limit
		[1 2 3]
		3)))
	     (1should
	      (equal
	       [1 2 3]
	       (compat--string-limit
		[1 2 3]
		4)))
	     (expect wrong-type-argument "abc" -1)
	     (expect wrong-type-argument "abc" 'a)
	     (expect wrong-type-argument 'a 2)
	     (expect wrong-type-argument 'a 'b))


(let* ((f (make-symbol "f"))
       (g (make-symbol "g"))
       (h (make-symbol "h"))
       (a (make-symbol "a"))
       (b (make-symbol "b")))
  (defalias f #'ignore)
  (defalias g f)
  (defalias h g)
  (defalias a b)
  (defalias b a)

  (compat-deftests function-alias-p
    (ought nil nil)
    (ought nil "")
    (ought nil #'ignore)
    (ought nil #'ignore)
    (ought (list #'ignore) f)
    (ought (list f #'ignore) g)
    (ought (list g f #'ignore) h)
    (expect cyclic-function-indirection a)
    (ought (list b) a t)))

(ert-deftest compat-ref-get-display-property-1 ()
  "Check basic `get-display-property' (the real thing) behaviour."
  (skip-unless (fboundp 'get-display-property))
  ;; based on tests from xdisp-test.el
  (with-temp-buffer
    (insert (propertize "foo" 'face 'bold 'display '(height 2.0))
            " bar")
    (should (eql 2.0 (get-display-property 1 'height)))
    (should (eql 2.0 (get-display-property 2 'height)))
    (should (eql nil (get-display-property 2 'width)))
    (should (eql nil (get-display-property 5 'height)))
    (should (eql nil (get-display-property 5 'height)))
    (should (eql nil (get-display-property 2 'bold)))
    (should (eql nil (get-display-property 5 'bold)))))

(ert-deftest compat-impl-get-display-property-1 ()
  "Check basic `get-display-property' (compat) behaviour."
  ;; based on tests from xdisp-test.el
  (with-temp-buffer
    (insert (propertize "foo" 'face 'bold 'display '(height 2.0))
            " bar")
    (should (eql 2.0 (compat--get-display-property 1 'height)))
    (should (eql 2.0 (compat--get-display-property 2 'height)))
    (should (eql nil (compat--get-display-property 2 'width)))
    (should (eql nil (compat--get-display-property 5 'height)))
    (should (eql nil (compat--get-display-property 5 'height)))
    (should (eql nil (compat--get-display-property 2 'bold)))
    (should (eql nil (compat--get-display-property 5 'bold)))))

(ert-deftest compat-ref-get-display-property-2 ()
  "Check if `get-display-property' (the real thing) handles the optional third argument."
  (skip-unless (fboundp 'get-display-property))
  ;; based on tests from xdisp-test.el
  (let ((str (concat
              (propertize "foo" 'face 'bold 'display '(height 2.0))
              " bar")))
    (should (eql 2.0 (get-display-property 1 'height str)))
    (should (eql 2.0 (get-display-property 2 'height str)))
    (should (eql nil (get-display-property 2 'width str)))
    (should (eql nil (get-display-property 5 'height str)))
    (should (eql nil (get-display-property 5 'height str)))
    (should (eql nil (get-display-property 2 'bold str)))
    (should (eql nil (get-display-property 5 'bold str)))))

(ert-deftest compat-impl-get-display-property-2 ()
  "Check if `get-display-property' (compat) handles the optional third argument."
  ;; based on tests from xdisp-test.el
  (let ((str (concat
              (propertize "foo" 'face 'bold 'display '(height 2.0))
              " bar")))
    (should (eql 2.0 (compat--get-display-property 1 'height str)))
    (should (eql 2.0 (compat--get-display-property 2 'height str)))
    (should (eql nil (compat--get-display-property 2 'width str)))
    (should (eql nil (compat--get-display-property 5 'height str)))
    (should (eql nil (compat--get-display-property 5 'height str)))
    (should (eql nil (compat--get-display-property 2 'bold str)))
    (should (eql nil (compat--get-display-property 5 'bold str)))))

(ert-deftest compat-ref-get-display-property-3 ()
  "Check if `get-display-property' (the real thing) handles multiple display properties."
  (skip-unless (fboundp 'get-display-property))
  ;; based on tests from xdisp-test.el
  (with-temp-buffer
    (insert (propertize "foo" 'face 'bold 'display '((height 2.0)
                                                     (space-width 4.0)))
            " bar")
    (should (eql 2.0 (get-display-property 1 'height)))
    (should (eql 2.0 (get-display-property 2 'height)))
    (should (eql nil (get-display-property 5 'height)))
    (should (eql 4.0 (get-display-property 1 'space-width)))
    (should (eql 4.0 (get-display-property 2 'space-width)))
    (should (eql nil (get-display-property 5 'space-width)))
    (should (eql nil (get-display-property 2 'width)))
    (should (eql nil (get-display-property 5 'width)))
    (should (eql nil (get-display-property 2 'bold)))
    (should (eql nil (get-display-property 5 'bold)))))

(ert-deftest compat-impl-get-display-property-3 ()
  "Check if `get-display-property' (compat) handles multiple display properties."
  ;; based on tests from xdisp-test.el
  (with-temp-buffer
    (insert (propertize "foo" 'face 'bold 'display '((height 2.0)
                                                     (space-width 4.0)))
            " bar")
    (should (eql 2.0 (compat--get-display-property 1 'height)))
    (should (eql 2.0 (compat--get-display-property 2 'height)))
    (should (eql nil (compat--get-display-property 5 'height)))
    (should (eql 4.0 (compat--get-display-property 1 'space-width)))
    (should (eql 4.0 (compat--get-display-property 2 'space-width)))
    (should (eql nil (compat--get-display-property 5 'space-width)))
    (should (eql nil (compat--get-display-property 2 'width)))
    (should (eql nil (compat--get-display-property 5 'width)))
    (should (eql nil (compat--get-display-property 2 'bold)))
    (should (eql nil (compat--get-display-property 5 'bold)))))

(ert-deftest compat-ref-get-display-property-4 ()
  "Check if `get-display-property' (the real thing) handles display property vectors."
  (skip-unless (fboundp 'get-display-property))
  ;; Based on tests from xdisp-test.el
  (with-temp-buffer
    (insert (propertize "foo bar" 'face 'bold
                        'display '[(height 2.0)
                                   (space-width 20)])
            " baz")
    (should (eql 2.0 (get-display-property 1 'height)))
    (should (eql 2.0 (get-display-property 2 'height)))
    (should (eql 2.0 (get-display-property 5 'height)))
    (should (eql nil (get-display-property 8 'height)))
    (should (eql 20 (get-display-property 1 'space-width)))
    (should (eql 20 (get-display-property 2 'space-width)))
    (should (eql 20 (get-display-property 5 'space-width)))
    (should (eql nil (get-display-property 8 'space-width)))
    (should (eql nil (get-display-property 2 'width)))
    (should (eql nil (get-display-property 5 'width)))
    (should (eql nil (get-display-property 8 'width)))
    (should (eql nil (get-display-property 2 'bold)))
    (should (eql nil (get-display-property 5 'bold)))
    (should (eql nil (get-display-property 8 'width)))))

(ert-deftest compat-impl-get-display-property-4 ()
  "Check if `get-display-property' handles display property vectors."
  ;; Based on tests from xdisp-test.el
  (with-temp-buffer
    (insert (propertize "foo bar" 'face 'bold
                        'display '[(height 2.0)
                                   (space-width 20)])
            " baz")
    (should (eql 2.0 (compat--get-display-property 1 'height)))
    (should (eql 2.0 (compat--get-display-property 2 'height)))
    (should (eql 2.0 (compat--get-display-property 5 'height)))
    (should (eql nil (compat--get-display-property 8 'height)))
    (should (eql 20 (compat--get-display-property 1 'space-width)))
    (should (eql 20 (compat--get-display-property 2 'space-width)))
    (should (eql 20 (compat--get-display-property 5 'space-width)))
    (should (eql nil (compat--get-display-property 8 'space-width)))
    (should (eql nil (compat--get-display-property 2 'width)))
    (should (eql nil (compat--get-display-property 5 'width)))
    (should (eql nil (compat--get-display-property 8 'width)))
    (should (eql nil (compat--get-display-property 2 'bold)))
    (should (eql nil (compat--get-display-property 5 'bold)))
    (should (eql nil (compat--get-display-property 8 'width)))))(ert-deftest compat-ref-file-name-absolute-p nil "Check if the real `file-name-absolute-p' works as expected."
	     (1should
	      (equal t
		     (file-name-absolute-p "/")))
	     (1should
	      (equal t
		     (file-name-absolute-p "/a")))
	     (1should
	      (equal nil
		     (file-name-absolute-p "a")))
	     (1should
	      (equal nil
		     (file-name-absolute-p "a/b")))
	     (1should
	      (equal nil
		     (file-name-absolute-p "a/b/")))
	     (1should
	      (equal t
		     (file-name-absolute-p "~")))
	     (if
		 (version< "27.1" emacs-version)
		 (progn
		   (1should
		    (equal t
			   (file-name-absolute-p "~/foo")))
		   (1should
		    (equal nil
			   (file-name-absolute-p "~foo")))
		   (1should
		    (equal nil
			   (file-name-absolute-p "~foo/")))))
	     (1should
	      (equal t
		     (file-name-absolute-p "~root")))
	     (1should
	      (equal t
		     (file-name-absolute-p "~root/")))
	     (1should
	      (equal t
		     (file-name-absolute-p "~root/file"))))
(ert-deftest compat-impl-file-name-absolute-p nil "Check if compat `file-name-absolute-p' works as expected."
	     (1should
	      (equal t
		     (compat--file-name-absolute-p "/")))
	     (1should
	      (equal t
		     (compat--file-name-absolute-p "/a")))
	     (1should
	      (equal nil
		     (compat--file-name-absolute-p "a")))
	     (1should
	      (equal nil
		     (compat--file-name-absolute-p "a/b")))
	     (1should
	      (equal nil
		     (compat--file-name-absolute-p "a/b/")))
	     (1should
	      (equal t
		     (compat--file-name-absolute-p "~")))
	     (if
		 (version< "27.1" emacs-version)
		 (progn
		   (1should
		    (equal t
			   (compat--file-name-absolute-p "~/foo")))
		   (1should
		    (equal nil
			   (compat--file-name-absolute-p "~foo")))
		   (1should
		    (equal nil
			   (compat--file-name-absolute-p "~foo/")))))
	     (1should
	      (equal t
		     (compat--file-name-absolute-p "~root")))
	     (1should
	      (equal t
		     (compat--file-name-absolute-p "~root/")))
	     (1should
	      (equal t
		     (compat--file-name-absolute-p "~root/file"))))


(let ((one (make-symbol "1"))
      (two (make-symbol "2"))
      (three (make-symbol "3"))
      (one.5 (make-symbol "1.5"))
      (eins (make-symbol "𝟙")))
  (put two 'derived-mode-parent one)
  (put one.5 'derived-mode-parent one)
  (put three 'derived-mode-parent two)
  (compat-deftests provided-mode-derived-p
    (ought one one one)
    (ought one two one)
    (ought one three one)
    (ought nil one eins)
    (ought nil two eins)
    (ought nil two one.5)
    (ought one two one.5 one)
    (ought two two one.5 two)
    (ought one three one.5 one)
    (ought two three one.5 one two)
    (ought two three one.5 two one)
    (ought three three one.5 two one three)
    (ought three three one.5 three two one)))(ert-deftest compat-ref-file-parent-directory nil "Check if the real `file-parent-directory' works as expected."
	     (1should
	      (equal nil
		     (file-parent-directory "/")))
	     (1should
	      (equal "/"
		     (file-parent-directory "/dir")))
	     (1should
	      (equal "./"
		     (file-parent-directory "dir")))
	     (1should
	      (equal "file/to/"
		     (file-parent-directory "file/to/dir")))
	     (1should
	      (equal "file/to/"
		     (file-parent-directory "file/to/dir/")))
	     (1should
	      (equal "/file/to/"
		     (file-parent-directory "/file/to/dir")))
	     (1should
	      (equal "/file/to/"
		     (file-parent-directory "/file/to/dir/"))))
(ert-deftest compat-impl-file-parent-directory nil "Check if compat `file-parent-directory' works as expected."
	     (1should
	      (equal nil
		     (compat--file-parent-directory "/")))
	     (1should
	      (equal "/"
		     (compat--file-parent-directory "/dir")))
	     (1should
	      (equal "./"
		     (compat--file-parent-directory "dir")))
	     (1should
	      (equal "file/to/"
		     (compat--file-parent-directory "file/to/dir")))
	     (1should
	      (equal "file/to/"
		     (compat--file-parent-directory "file/to/dir/")))
	     (1should
	      (equal "/file/to/"
		     (compat--file-parent-directory "/file/to/dir")))
	     (1should
	      (equal "/file/to/"
		     (compat--file-parent-directory "/file/to/dir/"))))
(ert-deftest compat-ref-string-equal-ignore-case nil "Check if the real `string-equal-ignore-case' works as expected."
	     (1should
	      (equal t
		     (string-equal-ignore-case "" "")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "a" "a")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "a" "A")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "A" "a")))
	     (1should
	      (equal nil
		     (string-equal-ignore-case "aA" "a")))
	     (1should
	      (equal nil
		     (string-equal-ignore-case "a" "Aa")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "aA" "aA")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "Aa" "Aa")))
	     (1should
	      (equal nil
		     (string-equal-ignore-case "aB" "aA")))
	     (1should
	      (equal nil
		     (string-equal-ignore-case "Ba" "Aa")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "AAA BBB" "AAA BBB")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "aaa BBB" "AAA BBB")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "AAA bbb" "AAA BBB")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "AAA BBB" "aaa BBB")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "AAA BBB" "AAA bbb")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "AAA BBB" "aaa bbb")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "AAA BBB" "aaa bbb")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "AAA bbb" "aaa bbb")))
	     (1should
	      (equal t
		     (string-equal-ignore-case "aaa BBB" "aaa bbb"))))
(ert-deftest compat-impl-string-equal-ignore-case nil "Check if compat `string-equal-ignore-case' works as expected."
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "" "")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "a" "a")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "a" "A")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "A" "a")))
	     (1should
	      (equal nil
		     (compat--string-equal-ignore-case "aA" "a")))
	     (1should
	      (equal nil
		     (compat--string-equal-ignore-case "a" "Aa")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "aA" "aA")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "Aa" "Aa")))
	     (1should
	      (equal nil
		     (compat--string-equal-ignore-case "aB" "aA")))
	     (1should
	      (equal nil
		     (compat--string-equal-ignore-case "Ba" "Aa")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "AAA BBB" "AAA BBB")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "aaa BBB" "AAA BBB")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "AAA bbb" "AAA BBB")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "AAA BBB" "aaa BBB")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "AAA BBB" "AAA bbb")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "AAA BBB" "aaa bbb")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "AAA BBB" "aaa bbb")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "AAA bbb" "aaa bbb")))
	     (1should
	      (equal t
		     (compat--string-equal-ignore-case "aaa BBB" "aaa bbb"))))
(ert-deftest compat-ref-compat-plist-get nil "Check if the real `compat-plist-get' works as expected."
	     (1should
	      (equal 1
		     (compat-plist-get
		      '(:one 1 :two 2 :three 3)
		      :one)))
	     (1should
	      (equal 2
		     (compat-plist-get
		      '(:one 1 :two 2 :three 3)
		      :two)))
	     (1should
	      (equal 3
		     (compat-plist-get
		      '(:one 1 :two 2 :three 3)
		      :three)))
	     (1should
	      (equal nil
		     (compat-plist-get
		      '(:one 1 :two 2 :three 3)
		      :four)))
	     (1should
	      (equal :one
		     (compat-plist-get
		      '(1 :one 2 :two 3 :three)
		      3 #'>)))
	     (1should
	      (equal :three
		     (compat-plist-get
		      '(1 :one 2 :two 3 :three)
		      3 #'<=)))
	     (1should
	      (equal nil
		     (compat-plist-get
		      '(1 :one 2 :two 3 :three)
		      4 #'<=))))
(ert-deftest compat-impl-compat-plist-get nil "Check if compat `compat-plist-get' works as expected."
	     (1should
	      (equal 1
		     (compat--compat-plist-get
		      '(:one 1 :two 2 :three 3)
		      :one)))
	     (1should
	      (equal 2
		     (compat--compat-plist-get
		      '(:one 1 :two 2 :three 3)
		      :two)))
	     (1should
	      (equal 3
		     (compat--compat-plist-get
		      '(:one 1 :two 2 :three 3)
		      :three)))
	     (1should
	      (equal nil
		     (compat--compat-plist-get
		      '(:one 1 :two 2 :three 3)
		      :four)))
	     (1should
	      (equal :one
		     (compat--compat-plist-get
		      '(1 :one 2 :two 3 :three)
		      3 #'>)))
	     (1should
	      (equal :three
		     (compat--compat-plist-get
		      '(1 :one 2 :two 3 :three)
		      3 #'<=)))
	     (1should
	      (equal nil
		     (compat--compat-plist-get
		      '(1 :one 2 :two 3 :three)
		      4 #'<=))))
(ert-deftest compat-ref-compat-plist-put nil "Check if the real `compat-plist-put' works as expected."
	     (1should
	      (equal
	       '(:one -1 :two 2 :three 3)
	       (compat-plist-put
		(list :one 1 :two 2 :three 3)
		:one -1)))
	     (1should
	      (equal
	       '(:one -1 :one 2 :one 3)
	       (compat-plist-put
		(list :one 1 :one 2 :one 3)
		:one -1)))
	     (1should
	      (equal
	       '(:zero 1 :one -1 :one 3)
	       (compat-plist-put
		(list :zero 1 :one 2 :one 3)
		:one -1)))
	     (1should
	      (equal
	       '(:one -1 :two 2 :three 3)
	       (compat-plist-put
		(list :one 1 :two 2 :three 3)
		:one -1)))
	     (1should
	      (equal
	       '(:one 1 :two 2 :three 3 :four -1)
	       (compat-plist-put
		(list :one 1 :two 2 :three 3)
		:four -1)))
	     (1should
	      (equal
	       '(1 :eins 2 :two 3 :three)
	       (compat-plist-put
		'(1 :one 2 :two 3 :three)
		3 :eins #'>)))
	     (1should
	      (equal
	       '(1 :one 2 :zwei 3 :three)
	       (compat-plist-put
		'(1 :one 2 :two 3 :three)
		2 :zwei #'<=)))
	     (1should
	      (equal
	       '(1 :one 2 :two 3 :three 4 :vier)
	       (compat-plist-put
		'(1 :one 2 :two 3 :three)
		4 :vier #'<=)))
	     (1should
	      (equal
	       '(1 :vier 2 :two 3 :three)
	       (compat-plist-put
		'(1 :one 2 :two 3 :three)
		4 :vier #'>))))
(ert-deftest compat-impl-compat-plist-put nil "Check if compat `compat-plist-put' works as expected."
	     (1should
	      (equal
	       '(:one -1 :two 2 :three 3)
	       (compat--compat-plist-put
		(list :one 1 :two 2 :three 3)
		:one -1)))
	     (1should
	      (equal
	       '(:one -1 :one 2 :one 3)
	       (compat--compat-plist-put
		(list :one 1 :one 2 :one 3)
		:one -1)))
	     (1should
	      (equal
	       '(:zero 1 :one -1 :one 3)
	       (compat--compat-plist-put
		(list :zero 1 :one 2 :one 3)
		:one -1)))
	     (1should
	      (equal
	       '(:one -1 :two 2 :three 3)
	       (compat--compat-plist-put
		(list :one 1 :two 2 :three 3)
		:one -1)))
	     (1should
	      (equal
	       '(:one 1 :two 2 :three 3 :four -1)
	       (compat--compat-plist-put
		(list :one 1 :two 2 :three 3)
		:four -1)))
	     (1should
	      (equal
	       '(1 :eins 2 :two 3 :three)
	       (compat--compat-plist-put
		'(1 :one 2 :two 3 :three)
		3 :eins #'>)))
	     (1should
	      (equal
	       '(1 :one 2 :zwei 3 :three)
	       (compat--compat-plist-put
		'(1 :one 2 :two 3 :three)
		2 :zwei #'<=)))
	     (1should
	      (equal
	       '(1 :one 2 :two 3 :three 4 :vier)
	       (compat--compat-plist-put
		'(1 :one 2 :two 3 :three)
		4 :vier #'<=)))
	     (1should
	      (equal
	       '(1 :vier 2 :two 3 :three)
	       (compat--compat-plist-put
		'(1 :one 2 :two 3 :three)
		4 :vier #'>))))
(ert-deftest compat-ref-compat-plist-get-member nil "Check if the real `compat-plist-get-member' works as expected."
	     (1should
	      (equal
	       '(:one 1 :two 2 :three 3)
	       (compat-plist-get-member
		'(:one 1 :two 2 :three 3)
		:one)))
	     (1should
	      (equal
	       '(:two 2 :three 3)
	       (compat-plist-get-member
		'(:one 1 :two 2 :three 3)
		:two)))
	     (1should
	      (equal
	       '(:three 3)
	       (compat-plist-get-member
		'(:one 1 :two 2 :three 3)
		:three)))
	     (1should
	      (equal nil
		     (compat-plist-get-member
		      '(:one 1 :two 2 :three 3)
		      :four)))
	     (1should
	      (equal
	       '(1 :one 2 :two 3 :three)
	       (compat-plist-get-member
		'(1 :one 2 :two 3 :three)
		3 #'>)))
	     (1should
	      (equal
	       '(3 :three)
	       (compat-plist-get-member
		'(1 :one 2 :two 3 :three)
		3 #'<=)))
	     (1should
	      (equal nil
		     (compat-plist-get-member
		      '(1 :one 2 :two 3 :three)
		      4 #'<=))))
(ert-deftest compat-impl-compat-plist-get-member nil "Check if compat `compat-plist-get-member' works as expected."
	     (1should
	      (equal
	       '(:one 1 :two 2 :three 3)
	       (compat--compat-plist-get-member
		'(:one 1 :two 2 :three 3)
		:one)))
	     (1should
	      (equal
	       '(:two 2 :three 3)
	       (compat--compat-plist-get-member
		'(:one 1 :two 2 :three 3)
		:two)))
	     (1should
	      (equal
	       '(:three 3)
	       (compat--compat-plist-get-member
		'(:one 1 :two 2 :three 3)
		:three)))
	     (1should
	      (equal nil
		     (compat--compat-plist-get-member
		      '(:one 1 :two 2 :three 3)
		      :four)))
	     (1should
	      (equal
	       '(1 :one 2 :two 3 :three)
	       (compat--compat-plist-get-member
		'(1 :one 2 :two 3 :three)
		3 #'>)))
	     (1should
	      (equal
	       '(3 :three)
	       (compat--compat-plist-get-member
		'(1 :one 2 :two 3 :three)
		3 #'<=)))
	     (1should
	      (equal nil
		     (compat--compat-plist-get-member
		      '(1 :one 2 :two 3 :three)
		      4 #'<=))))


(ert-deftest compat-ref-define-key ()
  "Check if the real `define-key' handles the REMOVE argument."
  (skip-unless (version< "29" emacs-version))
  (let ((map (make-sparse-keymap))
        (super (make-sparse-keymap)))
    (set-keymap-parent map super)
    (define-key super "a" 'always)
    ;; We should be able to command a key that was just bound.
    (define-key map "a" 'ignore)
    (should (eq (lookup-key map "a") 'ignore))
    (should (eq (lookup-key super "a") 'always))
    ;; After removing it we should find the key in the parent map.
    (define-key map "a" nil t)
    (should (eq (lookup-key map "a") 'always))
    (should (eq (lookup-key super "a") 'always))
    ;; Repeating this shouldn't change the result
    (define-key map "a" 'anything t)
    (should (eq (lookup-key map "a") 'always))
    (should (eq (lookup-key super "a") 'always))
    ;; Removing it from the parent map should remove it from the child
    ;; map as well.
    (define-key super "a" 'anything t)
    (should (eq (lookup-key map "a") nil))
    (should (eq (lookup-key super "a") nil))))

(ert-deftest compat-impl-efine-key ()
  "Check if compat `define-key' handles the REMOVE argument."
  (let ((map (make-sparse-keymap))
        (super (make-sparse-keymap)))
    (set-keymap-parent map super)
    (define-key super "a" 'always)
    ;; We should be able to command a key that was just bound.
    (define-key map "a" 'ignore)
    (should (eq (lookup-key map "a") 'ignore))
    (should (eq (lookup-key super "a") 'always))
    ;; After removing it we should find the key in the parent map.
    (compat-define-key map "a" nil t)
    (should (eq (lookup-key map "a") 'always))
    (should (eq (lookup-key super "a") 'always))
    ;; Repeating this shouldn't change the result
    (compat-define-key map "a" 'anything t)
    (should (eq (lookup-key map "a") 'always))
    (should (eq (lookup-key super "a") 'always))
    ;; Removing it from the parent map should remove it from the child
    ;; map as well.
    (compat-define-key super "a" 'anything t)
    (should (eq (lookup-key map "a") nil))
    (should (eq (lookup-key super "a") nil))))

(ert-deftest compat-ref-while-let ()
  "Check if the real `while-let' behaves as assumed."
  (skip-unless (fboundp 'while-let))
  ;; Basic test
  (let ((list (list 1 2 3 4 5)))
    (while-let ((one (pop list))
                (two (pop list)))
      (should one)
      (should two)
      (should (< one two)))
    (should (null list)))
  ;; Practical test
  (with-temp-buffer
    (insert "1 2 3 4 1 2 3 4 1 2 3 4")
    (goto-char (point-min))
    (let ((count 0))
      (while-let (((search-forward-regexp "2" nil t))
                  (match (match-string 0))
                  ((string= match "2")))
        (setq count (1+ count)))
      (should (= count 3))))
  ;; Edge cases
  (catch 'break
    (while-let ()
      (throw 'break (should t))))
  (while-let ((()))
    (should nil))
  (while-let ((test nil))
    (should nil))
  (while-let (((ignore)))
    (should nil)))

(ert-deftest compat-impl-while-let ()
  "Check if the compat `while-let' behaves as expected."
  ;; Basic test
  (let ((list (list 1 2 3 4 5)))
    (compat--while-let ((one (pop list))
                (two (pop list)))
      (should one)
      (should two)
      (should (< one two)))
    (should (null list)))
  ;; Practical test
  (with-temp-buffer
    (insert "1 2 3 4 1 2 3 4 1 2 3 4")
    (goto-char (point-min))
    (let ((count 0))
      (compat--while-let (((search-forward-regexp "2" nil t))
                  (match (match-string 0))
                  ((string= match "2")))
        (setq count (1+ count)))
      (should (= count 3))))
  ;; Edge cases
  (catch 'break
    (compat--while-let ()
      (throw 'break (should t))))
  (compat--while-let ((()))
    (should nil))
  (compat--while-let ((test nil))
    (should nil))
  (compat--while-let (((ignore)))
    (should nil)))

(provide 'compat-tests)
;;; compat-tests.el ends here
