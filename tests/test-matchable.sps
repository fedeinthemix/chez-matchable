#! /usr/bin/env scheme-script

;;; Copyright (c) 2016 Federico Beffa <beffa@fbengineering.ch>
;;; 
;;; Permission to use, copy, modify, and distribute this software for
;;; any purpose with or without fee is hereby granted, provided that the
;;; above copyright notice and this permission notice appear in all
;;; copies.
;;; 
;;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
;;; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
;;; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
;;; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
;;; DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
;;; OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
;;; TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;;; PERFORMANCE OF THIS SOFTWARE.


(import (rnrs)
        (matchable)
        (srfi :78))

(check (match '(1 2 3)
         ((a (? odd? b) c) b)
         (_ #f))
       => #f)

(check (match '(1 2 3)
         ((a (? even? b) c) b)
         (_ #f))
       => 2)

(check (match '(1 2 3)
         ((a b ...) b)
         (_ #f))
       => '(2 3))

#!chezscheme
(check (match '(1 2 3)
         ((a b ..1) b)
         (_ #f))
       => '(2 3))

(check (match '(1)
         ((a b ...) b)
         (_ #f))
       => '())

;; Incompatible with R6RS
(check (match '(1 2 3)
         ((a :_ :_) a)
         (_ #f))
       => 1)

(check (match '(1 2 3)
         (('a b c) b)
         (_ #f))
       => #f)

(check (match '(1 2 3)
         (`(1 ,b 3) b)
         (_ #f))
       => 2)

(check (match '(1 2 3 3 3)
         ((a b c c ...) c)
         (_ #f))
       => '(3 3))

(check (match '(1 2 3 4)
         ((a b ... c) b)
         (_ #f))
       => '(2 3))

(check (match '(1 2 3)
         ((and t (a b c)) (list `(b . ,b) `(t . ,t)))
         (_ #f))
       => '((b . 2) (t . (1 2 3))))

(check (match 1
         ((or 1 2) #t)
         (_ #f))
       => #t)

(check (match '(1 2)
         ((or (a b) (a a b)) a)
         (_ #f))
       => 1)

;; This fails if we import (chezscheme) instead of (rnrs).
(check (match 1
         ((not 2) #t)
         (_ #f))
       => #t)

(check (match '(1 . 2)
         ((= car x) x)
         (_ #f))
       => 1)

(check
 (let* ((square (lambda (x) (expt x 2))))
   (match 4
     ((= square x) x)
     (_ #f)))
 => 16)

(check
 (let* ((square* (lambda (x) `(x . ,(expt x 2)))))
   (match 4
     ((= square* x) x)
     (_ #f)))
 => '(x . 16))

(check 
 (let* ((square* (lambda (x) `(,x . ,(expt x 2)))))
   (match 4
     ((= square* (x . y)) x)
     (_ #f)))
 => 4)

;; (let ()
;;   (define-record-type <employee>
;;     (make-employee name title)
;;     employee?
;;     (name get-name)
;;     (title get-title))
;;   (let ((result
;;          (match (make-employee "Bob" "Doctor")
;;            (($ <employee> n t) (list t n)))))
;;     (display "$ srfi-9: ")
;;     (display result)
;;     (newline)))

(check 
 (let ()
   (define-record-type employee (fields name title))
   (match (make-employee "Fede" "Dr.")
     (($ employee n t) (list t n))
     (_ #f)))
 => '("Dr." "Fede"))

;; (let ()
;;   (define-record-type <employee>
;;     (make-employee name title)
;;     employee?
;;     (name get-name)
;;     (title get-title))
;;   (let ((result
;;          (match (make-employee "Bob" "Doctor")
;;            ((@ <employee> (title t) (name n)) (list t n)))))
;;     (display "@ srfi-9: ")
;;     (display result)
;;     (newline)))

(check
 (let ()
   (define-record-type employee (fields name title))
   (match (make-employee "Fede" "Dr.")
     ((@ employee (title t) (name n)) (list t n))
     (_ #f)))
 => '("Dr." "Fede"))

(check
 (let ((x (cons 1 2)))
   (match x
     ((1 . (set! s)) (s 3) x)
     (_ #f)))
 => '(1 . 3))

(check
 (match '(1 . 2)
   ((1 . (get! g)) (g))
   (_ #f))
 => 2)

(check
 (match '(a (a (a b)))
   ((x *** 'b) x)
   (_ #f))
 => '(a a a))

(check
 (match '(a (b) (c (d e) (f g)))
   ((x *** 'g) x)
   (_ #f))
 => '(a c f))

(check
 (match '(a (b) (c (d e) (f g)))
   ((:_ *** 'g) 'got-it)
   (_ #f))
 => 'got-it)

(check
 ((match-lambda ((a b) b)
                (_ #f))
  '(1 2))
 => 2)

(check
 (let* ((x (list 1 (list 2 3))))
   (match x
     [(a (b (set! setit)))  (setit 4) x]
     (_ #f)))
 => '(1 (2 4)))

(check
 (match-let ([(x y z) (list 1 2 3)])
   z)
 => 3)

(check-report)
