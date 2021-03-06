#lang racket/base
(require (for-syntax racket/base)
         "test-suite-utils.rkt")

(define-syntax (test-search stx)
  (syntax-case stx ()
    [(_ args ...)
     (with-syntax ([line (syntax-line stx)])
       #'(test-search/proc line args ...))]))

;; creates a search text, binds it to 't' and then, 
;; for each expression in 'commands', evaluates it in a let 
;; binding 't'. In between each call to commands, it waits
;; for the search text to quiesce and then finally gets
;; the search bubbles, comparing them to 'bubble-table'
(define (test-search/proc line commands bubble-table)
  ;(printf "running test on line ~s\n" line)
  (test
   (string->symbol (format "search.rkt: line ~a pos immediately" line))
   (lambda (x) (equal? bubble-table x))
   (lambda ()
     (send-sexp-to-mred
      `(let ([c (make-channel)])
         (queue-callback
          (λ () (channel-put c (new (text:searching-mixin (editor:keymap-mixin text:basic%))))))
         (define t (channel-get c))
         (define (wait)
           (let loop ()
             (queue-callback 
              (λ ()
                (channel-put c (send t search-updates-pending?)))
              #f)
             (when (channel-get c)
               (loop))))
         ,@(apply
            append
            (for/list ([command (in-list commands)])
              (list `(queue-callback (λ () ,command (channel-put c #f)))
                    '(channel-get c)
                    '(wait))))
         (queue-callback 
          (λ ()
            (channel-put c (send t get-search-bubbles)))
          #f)
         (channel-get c))))))

(test-search (list '(begin (send t insert "") 
                           (send t set-searching-state "aba" #t #f)
                           (send t set-position 0 0)))
             '())
(test-search (list '(begin (send t insert "") 
                           (send t set-searching-state "aba" #t #f))
                   '(send t set-position 0 0))
             '())
(test-search (list '(begin (send t insert "aba") 
                           (send t set-searching-state "aba" #t #f) 
                           (send t set-position 0 0)))
             `(((0 . 3) normal-search-color)))
(test-search (list '(begin (send t insert "aba") 
                           (send t set-searching-state "aba" #t #f) )
                   '(send t set-position 0 0))
             `(((0 . 3) normal-search-color)))

(test-search (list '(begin (send t insert "aba aba")
                           (send t set-searching-state "aba" #t #f)
                           (send t set-position 0 0)))
             `(((0 . 3) normal-search-color)
               ((4 . 7) normal-search-color)))
(test-search (list '(begin (send t insert "aba aba")
                           (send t set-searching-state "aba" #t #f))
                   '(send t set-position 0 0))
             `(((0 . 3) normal-search-color)
               ((4 . 7) normal-search-color)))


(test-search (list '(begin (send t insert "abaaba")
                           (send t set-searching-state "aba" #t #f)
                           (send t set-position 0 0)))
             `(((0 . 3) normal-search-color)
               ((3 . 6) normal-search-color)))
(test-search (list '(begin (send t insert "abaaba")
                           (send t set-searching-state "aba" #t #f))
                   '(send t set-position 0 0))
             `(((0 . 3) normal-search-color)
               ((3 . 6) normal-search-color)))

(test-search (list '(begin (send t insert "abababa")
                           (send t set-searching-state "aba" #t #f)
                           (send t set-position 0 0)))
             `(((0 . 3) normal-search-color)
               ((4 . 7) normal-search-color)))
(test-search (list '(begin (send t insert "abababa")
                           (send t set-searching-state "aba" #t #f))
                   '(send t set-position 0 0))
             `(((0 . 3) normal-search-color)
               ((4 . 7) normal-search-color)))

(test-search (list '(begin (send t insert "Aba")
                           (send t set-searching-state "aba" #t #f)
                           (send t set-position 0 0)))
             '())
(test-search (list '(begin (send t insert "Aba")
                           (send t set-searching-state "aba" #t #f))
                   '(send t set-position 0 0))
             '())
(test-search (list '(begin (send t insert "Aba")
                           (send t set-searching-state "aba" #f #f)
                           (send t set-position 0 0)))
             `(((0 . 3) normal-search-color)))
(test-search (list '(begin (send t insert "Aba")
                           (send t set-searching-state "aba" #f #f))
                   '(send t set-position 0 0))
             `(((0 . 3) normal-search-color)))

(test-search (list '(begin (send t set-searching-state "aba" #t 0)
                           (send t set-position 0)))
             '())

(test-search (list '(begin (send t insert "aba")
                           (send t set-searching-state "aba" #f #t)
                           (send t set-position 0 0)))
             `(((0 . 3) dark-search-color)))
(test-search (list '(begin (send t insert "aba")
                           (send t set-searching-state "aba" #f #t))
                   '(send t set-position 0 0))
             `(((0 . 3) dark-search-color)))

(test-search (list '(begin (send t insert "abababa")
                           (send t set-searching-state "aba" #f #t)
                           (send t set-position 0 0)))
             `(((0 . 3) dark-search-color) 
               ((4 . 7) light-search-color)))
(test-search (list '(begin (send t insert "abababa")
                           (send t set-searching-state "aba" #f #t))
                   '(send t set-position 0 0))
             `(((0 . 3) dark-search-color) 
               ((4 . 7) light-search-color)))

(test-search (list '(begin (send t insert "aba aba aba")
                           (send t set-searching-state "aba" #f #t)
                           (send t set-position 1 1)))
             `(((0 . 3) light-search-color)
               ((4 . 7) dark-search-color)
               ((8 . 11) light-search-color)))
(test-search (list '(begin (send t insert "aba aba aba")
                           (send t set-searching-state "aba" #f #t))
                   '(send t set-position 1 1))
             `(((0 . 3) light-search-color)
               ((4 . 7) dark-search-color)
               ((8 . 11) light-search-color)))

(test-search (list '(begin (send t insert "aba")
                           (send t set-searching-state "aba" #f #t))
                   '(send t set-position 0 0)
                   '(send t set-position 3 3))
             `(((0 . 3) light-search-color)))
(test-search (list '(begin (send t insert "aba")
                           (send t set-searching-state "aba" #f #t))
                   '(send t set-position 0 0)
                   '(send t set-position 1 1))
             `(((0 . 3) light-search-color)))

(test-search (list '(begin (send t insert "aba")
                           (send t set-searching-state "aba" #f #t))
                   '(send t set-searching-state #f #f #f))
             `())
