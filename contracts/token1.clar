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

(define-read-only (get-balance (owner principal))
    (ok (ft-get-balance TOKEN1 owner))
)

(define-read-only (get-name)
    (ok "TOKEN1")
)

(define-read-only (get-symbol)
    (ok "TO1")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply TOKEN1))
)

(define-read-only (get-token-uri)
  (ok (some u"https://token1.com")))


(ft-mint? TOKEN1 u1000000000000 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
