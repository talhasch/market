(use-trait ft-trait .ft-trait.ft-trait)

;; constants

(define-constant self (as-contract tx-sender))

;; data-var 

(define-data-var next-order-id uint u0)
(define-data-var admin principal tx-sender)
(define-data-var fee-pct uint u100) ;; 1.0% 
(define-data-var fee-to principal tx-sender)

;; maps 

(define-map ft-whitelist principal bool)
(define-map orders { order-id: uint } { seller: principal, ft: principal, bid: uint, ask: uint })

;; errors

(define-constant err-min-ask (err u90))
(define-constant err-ft-not-whitelisted (err u100))
(define-constant err-ft-transfer-error (err u110))
(define-constant err-order-not-found (err u120))
(define-constant err-not-your-order (err u130))
(define-constant err-your-order (err u140))
(define-constant err-incorrect-ft (err u150))
(define-constant err-coin-transfer-error (err u160))
(define-constant err-admin-only (err u170))
(define-constant err-max-fee (err u180))
(define-constant err-already-whitelisted (err u190))

;; getters

(define-read-only (get-next-order-id) (var-get next-order-id))
(define-read-only (get-admin) (var-get admin))
(define-read-only (get-fee-pct) (var-get fee-pct))
(define-read-only (get-fe-to) (var-get fee-to))
(define-read-only (get-ft-whitelist (ft <ft-trait>)) (map-get? ft-whitelist (contract-of ft)))
(define-read-only (get-order (order-id uint)) (map-get? orders {order-id: order-id}))


;; trade functions

(define-public (create-order (bid uint) (ask uint) (ft <ft-trait>)) 
    (let  
        (
            (order-id (var-get next-order-id))
            (ft-address (contract-of ft))
        )
        (asserts! (> ask u100) err-min-ask)
        (asserts! (is-some (map-get? ft-whitelist ft-address)) err-ft-not-whitelisted)
        (unwrap! (contract-call? ft transfer bid tx-sender self none) err-ft-transfer-error)
        (map-insert orders {order-id: order-id} {seller: tx-sender, ft: ft-address, bid: bid, ask: ask})
        (var-set next-order-id (+ (var-get next-order-id) u1))
        (print {op: "create-order", order-id: order-id, owner: tx-sender, ft: ft-address, bid: bid, ask: ask})
        (ok order-id)
    )
)

(define-public (cancel-order (order-id uint) (ft <ft-trait>))
    (let (
            (order (unwrap! (map-get? orders { order-id: order-id }) err-order-not-found))
        ) 
        (asserts! (is-eq tx-sender (get seller order)) err-not-your-order)
        (let
            (
                (txsender tx-sender)
            )
            (unwrap! (as-contract (contract-call? ft transfer (get bid order) self txsender none)) err-ft-transfer-error)
            (map-delete orders {order-id: order-id})
            (print {op: "cancel-order", order-id: order-id})
            (ok order-id)
        )
    )
)

(define-public (update-order (order-id uint) (ask uint))
    (let (
            (order (unwrap! (map-get? orders { order-id: order-id }) err-order-not-found))
        ) 
        (asserts! (is-eq tx-sender (get seller order)) err-not-your-order)
        (asserts! (> ask u100) err-min-ask)
        (map-set orders {order-id: order-id} (merge order {ask: ask}))
        (print {op: "update-order", order-id: order-id, ask: ask})
        (ok order-id)
    )
)

(define-public (fill-order (order-id uint) (ft <ft-trait>))
  (let (
            (order (unwrap! (map-get? orders { order-id: order-id }) err-order-not-found))
            (ask (get ask order))
            (fee (/ (* ask (var-get fee-pct)) u10000))
        ) 
        (asserts! (not (is-eq tx-sender (get seller order))) err-your-order)
        (asserts! (is-eq (contract-of ft) (get ft order)) err-incorrect-ft)
        (unwrap! (stx-transfer? (- ask fee) tx-sender (get seller order)) err-coin-transfer-error)
        (unwrap! (stx-transfer? fee tx-sender (var-get fee-to)) err-coin-transfer-error)
        (let 
            (
                (txsender tx-sender)
            )
            (unwrap! (as-contract (contract-call? ft transfer (get bid order) self txsender none)) err-ft-transfer-error)
            (map-delete orders {order-id: order-id})
            (print {op: "fill-order", order-id: order-id})
            (ok order-id)
        )
    )
)

;; admin only 

(define-public (set-admin (new principal))
    (begin 
        (asserts! (is-eq tx-sender (var-get admin)) err-admin-only)
        (var-set admin new)
        (print {op: "set-admin", new: new})
        (ok u1)
    )
)

(define-public (set-fee-to (new principal))
    (begin 
        (asserts! (is-eq tx-sender (var-get admin)) err-admin-only)
        (var-set fee-to new)
        (print {op: "set-fee-to", new: new})
        (ok u1)
    )
)

(define-public (set-fee-pct (new uint))
    (begin 
        (asserts! (is-eq tx-sender (var-get admin)) err-admin-only)
        (asserts! (<= new u500) err-max-fee) ;; max 5.0% 
        (print {op: "set-fee-pct", new: new})
        (var-set fee-pct new)
        (ok u1)
    )
)

(define-public (whitelist-ft (ft <ft-trait>))
    (begin 
        (asserts! (is-eq tx-sender (var-get admin)) err-admin-only)
        (asserts! (not (is-some (map-get? ft-whitelist (contract-of ft)))) err-already-whitelisted)
        (map-set ft-whitelist (contract-of ft) true)
        (print {op: "whitelist-ft", ft: ft})
        (ok u1)
    )
)

(define-public (rm-whitelist-ft (ft <ft-trait>))
    (begin 
        (asserts! (is-eq tx-sender (var-get admin)) err-admin-only)
        (asserts! (is-some (map-get? ft-whitelist (contract-of ft))) err-ft-not-whitelisted)
        (map-delete ft-whitelist (contract-of ft))
        (print {op: "rm-whitelist-ft", ft: ft})
        (ok u1)
    )
)

