(impl-trait .ft-trait.ft-trait)

(define-fungible-token TOKEN1 u1000000000000)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? TOKEN1 amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-public (get-balance (owner principal))
    (ok (ft-get-balance TOKEN1 owner))
)

(define-public (get-name)
    (ok "TOKEN1")
)

(define-public (get-symbol)
    (ok "TO1")
)

(define-public (get-decimals)
    (ok u6)
)

(define-public (get-total-supply)
    (ok (ft-get-supply TOKEN1))
)

(define-public (get-token-uri)
  (ok (some u"https://token1.com")))
