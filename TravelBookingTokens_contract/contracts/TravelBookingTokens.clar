
;; title: TravelBookingTokens
;; version: 1.0.0
;; summary: A token reward distribution smart contract for travel platform booking rewards
;; description: This contract manages the distribution of TBT (TravelBookingTokens) as rewards 
;;              for users who complete travel bookings on the platform. It includes features for
;;              minting, transferring, and managing reward distributions.

;; traits
;; This contract implements SIP-010 standard functions without trait implementation
;; for better compatibility in development environments

;; token definitions
(define-fungible-token travel-booking-token)

;; constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_INSUFFICIENT_BALANCE (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_UNAUTHORIZED (err u103))
(define-constant ERR_BOOKING_EXISTS (err u104))
(define-constant ERR_BOOKING_NOT_FOUND (err u105))
(define-constant ERR_ALREADY_CLAIMED (err u106))

;; Token metadata
(define-constant TOKEN_NAME "TravelBookingToken")
(define-constant TOKEN_SYMBOL "TBT")
(define-constant TOKEN_DECIMALS u6)

;; data vars
(define-data-var token-uri (string-utf8 256) u"")
(define-data-var total-supply uint u0)
(define-data-var reward-rate uint u100000000) ;; 100 TBT per booking (with 6 decimals)
(define-data-var contract-paused bool false)

;; data maps
;; Track user balances
(define-map balances principal uint)

;; Track booking rewards
(define-map booking-rewards 
  {booking-id: (string-ascii 64), user: principal} 
  {amount: uint, claimed: bool, booking-date: uint}
)

;; Track authorized reward distributors
(define-map authorized-distributors principal bool)

;; Track total rewards claimed by user
(define-map user-total-rewards principal uint)

;; public functions

;; SIP-010 Standard Functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR_UNAUTHORIZED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    (ft-transfer? travel-booking-token amount sender recipient)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (ft-mint? travel-booking-token amount recipient))
    (var-set total-supply (+ (var-get total-supply) amount))
    (ok true)
  )
)

;; Reward Distribution Functions
(define-public (distribute-booking-reward (booking-id (string-ascii 64)) (user principal))
  (let (
    (reward-amount (var-get reward-rate))
  )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) 
                  (default-to false (map-get? authorized-distributors tx-sender))) 
              ERR_UNAUTHORIZED)
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? booking-rewards {booking-id: booking-id, user: user})) ERR_BOOKING_EXISTS)
    
    ;; Record the booking reward
    (map-set booking-rewards 
      {booking-id: booking-id, user: user}
      {amount: reward-amount, claimed: false, booking-date: block-height}
    )
    
    ;; Mint tokens to the user
    (try! (ft-mint? travel-booking-token reward-amount user))
    (var-set total-supply (+ (var-get total-supply) reward-amount))
    
    ;; Update user's total rewards
    (map-set user-total-rewards 
      user 
      (+ (default-to u0 (map-get? user-total-rewards user)) reward-amount)
    )
    
    (ok reward-amount)
  )
)

(define-public (claim-booking-reward (booking-id (string-ascii 64)))
  (let (
    (booking-data (unwrap! (map-get? booking-rewards {booking-id: booking-id, user: tx-sender}) ERR_BOOKING_NOT_FOUND))
    (reward-amount (get amount booking-data))
  )
    (asserts! (not (get claimed booking-data)) ERR_ALREADY_CLAIMED)
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    
    ;; Mark as claimed
    (map-set booking-rewards 
      {booking-id: booking-id, user: tx-sender}
      (merge booking-data {claimed: true})
    )
    
    ;; Mint additional tokens as claiming bonus (10% bonus)
    (let ((bonus-amount (/ reward-amount u10)))
      (try! (ft-mint? travel-booking-token bonus-amount tx-sender))
      (var-set total-supply (+ (var-get total-supply) bonus-amount))
      
      ;; Update user's total rewards
      (map-set user-total-rewards 
        tx-sender 
        (+ (default-to u0 (map-get? user-total-rewards tx-sender)) bonus-amount)
      )
      
      (ok bonus-amount)
    )
  )
)

;; Admin Functions
(define-public (set-reward-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (asserts! (> new-rate u0) ERR_INVALID_AMOUNT)
    (var-set reward-rate new-rate)
    (ok true)
  )
)

(define-public (authorize-distributor (distributor principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (map-set authorized-distributors distributor true)
    (ok true)
  )
)

(define-public (revoke-distributor (distributor principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (map-delete authorized-distributors distributor)
    (ok true)
  )
)

(define-public (pause-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (var-set contract-paused true)
    (ok true)
  )
)

(define-public (unpause-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (var-set contract-paused false)
    (ok true)
  )
)

(define-public (set-token-uri (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (var-set token-uri uri)
    (ok true)
  )
)

;; read only functions

;; SIP-010 Standard Read-Only Functions
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance travel-booking-token who))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

;; Custom Read-Only Functions
(define-read-only (get-reward-rate)
  (var-get reward-rate)
)

(define-read-only (is-authorized-distributor (distributor principal))
  (default-to false (map-get? authorized-distributors distributor))
)

(define-read-only (get-booking-reward (booking-id (string-ascii 64)) (user principal))
  (map-get? booking-rewards {booking-id: booking-id, user: user})
)

(define-read-only (get-user-total-rewards (user principal))
  (default-to u0 (map-get? user-total-rewards user))
)

(define-read-only (is-contract-paused)
  (var-get contract-paused)
)

(define-read-only (get-contract-owner)
  CONTRACT_OWNER
)

;; private functions
;; No private functions needed for this implementation
