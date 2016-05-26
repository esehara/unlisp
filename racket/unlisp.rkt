#lang racket
(require rackunit)
;; =============
;; define Tokens
;; =============
;; -- types
(define INTEGER  1)
(define ATOM     2)
(define LIST     3)
(define FUNCTION 4)
(define ERROR    5)

(require rackunit)
(define token%
  (class object%
    (init t v)
    (define token-type t)
    (define value v)
  
    (super-new)
    
    (define/public (integer?) (= INTEGER token-type))
    (define/public (atom?) (= ATOM token-type))
    (define/public (list?) (= LIST token-type))
    (define/public (error?) (= ERROR token-type))
    (define/public (get-value) value)
    ))

;; ==========
;; Lexer?
;; ==========

(define (tokenize str)
  (cond 
    [(list? str) (new token% [t LIST] [v (list-tokenize str)])]
    [(regexp-match-exact? #px"\\d+" str)
     (new token% [t INTEGER] [v (string->number str)])]
    [(regexp-match-exact? #px"^\\D.*" str)
     (new token% [t ATOM] [v str])]
    [else (new token% [t ERROR] [v str])]))

(define (list-tokenize lst) (map tokenize lst))

;; =======
;; parse
;; =======
(define (make-token target)
  (cond [(integer? target)
         (new token% [t INTEGER] [v target])]))

(define (tokens->parser lst)
  (let* ([tokens (list-tokenize lst)]
         [first-token (car tokens)])
    (cond [(send first-token atom?)
           (atom<-apply tokens)])))

(define (atom<-apply tokens)
  (let* ([first-token (car tokens)]
         [first-value (send first-token get-value)])
    (cond [(string=? first-value "+")
           (make-token 
            (apply + (map (lambda (x) (send x get-value)) (cdr tokens))))])))


                                     
                                     
;; =============================================
;; Specification
;; =============================================
;; - Step 1. Tokenize
(check-true (send (tokenize "1") integer?))
(check-equal? (send (tokenize "1") get-value) 1)
(check-true (send (tokenize "foobar") atom?))
(check-true (send (tokenize (list "+" "1" "1")) list?)) 
(check-true (send (tokenize "") error?))


;; -- step 1.1 Tokenlist
(check-true (let ([test-list (list-tokenize (list "+" "1" "1"))])
              (and (send (first test-list)  atom?)
                   (send (second test-list) integer?)
                   (send (third test-list) integer?))))

(check-true (let* ([test-list (list-tokenize
                               (list "+" (list "+" "1" "1") "1"))]
                   [test-value (send (second test-list) get-value)])
              (and (send (first test-list) atom?)
                   (send (second test-list) list?)
                   (send (first test-value) atom?)
                   (send (second test-value) integer?)
                   (send (third test-value) integer?)
                   (send (third test-list) integer?))))

;; - Step.2 Parser
(check-equal? (send (tokens->parser (list "+" "1" "1")) get-value) 2)