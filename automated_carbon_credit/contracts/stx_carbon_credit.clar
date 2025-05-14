;; Carbon Credit Trading System
;; This contract implements a system for tokenizing and trading carbon credits
;; with built-in verification mechanisms.

;; Define contract constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-AMOUNT (err u101))
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))
(define-constant ERR-INVALID-VERIFIER (err u103))
(define-constant ERR-CREDIT-NOT-FOUND (err u104))
(define-constant ERR-ALREADY-VERIFIED (err u105))
(define-constant ERR-NOT-VERIFIED (err u106))
(define-constant ERR-ALREADY-RETIRED (err u107))

;; Data structures

;; Carbon credit type - represents different types of carbon credits
;; (e.g., forestry, renewable energy, etc.)
(define-map credit-types 
  { credit-type-id: uint }
  { 
    name: (string-ascii 50),
    description: (string-ascii 255)
  }
)

;; Carbon credit batches - represents a batch of carbon credits
(define-map credit-batches
  { batch-id: uint }
  {
    credit-type-id: uint,
    issuer: principal,
    amount: uint,
    vintage-year: uint,
    project-location: (string-ascii 100),
    verified: bool,
    retired: bool,
    metadata-url: (string-utf8 255)
  }
)

;; Verifiers - approved entities that can verify carbon credits
(define-map verifiers
  { verifier: principal }
  { 
    name: (string-ascii 100),
    approved: bool
  }
)

;; User balances - track how many credits of each batch a user holds
(define-map balances
  { owner: principal, batch-id: uint }
  { amount: uint }
)

;; Variables for tracking IDs
(define-data-var last-credit-type-id uint u0)
(define-data-var last-batch-id uint u0)

;; Functions

;; Initialize a new credit type
(define-public (register-credit-type (name (string-ascii 50)) (description (string-ascii 255)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (let ((new-id (+ (var-get last-credit-type-id) u1)))
      (map-set credit-types { credit-type-id: new-id } { name: name, description: description })
      (var-set last-credit-type-id new-id)
      (ok new-id))))

;; Register a new verifier
(define-public (register-verifier (verifier principal) (name (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set verifiers { verifier: verifier } { name: name, approved: true })
    (ok true)))

;; Remove a verifier
(define-public (remove-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-delete verifiers { verifier: verifier })
    (ok true)))

;; Issue new carbon credits
(define-public (issue-carbon-credits
                (credit-type-id uint)
                (amount uint)
                (vintage-year uint)
                (project-location (string-ascii 100))
                (metadata-url (string-utf8 255)))
  (let ((new-batch-id (+ (var-get last-batch-id) u1)))
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    ;; Check if credit type exists
    (asserts! (is-some (map-get? credit-types { credit-type-id: credit-type-id })) ERR-CREDIT-NOT-FOUND)
    
    ;; Create new batch
    (map-set credit-batches
      { batch-id: new-batch-id }
      {
        credit-type-id: credit-type-id,
        issuer: tx-sender,
        amount: amount,
        vintage-year: vintage-year,
        project-location: project-location,
        verified: false,
        retired: false,
        metadata-url: metadata-url
      }
    )
    
    ;; Set initial balance for issuer
    (map-set balances
      { owner: tx-sender, batch-id: new-batch-id }
      { amount: amount }
    )
    
    ;; Update batch counter
    (var-set last-batch-id new-batch-id)
    (ok new-batch-id)))

;; Verify a batch of carbon credits
(define-public (verify-batch (batch-id uint))
  (let ((batch (unwrap! (map-get? credit-batches { batch-id: batch-id }) ERR-CREDIT-NOT-FOUND))
        (verifier-info (unwrap! (map-get? verifiers { verifier: tx-sender }) ERR-INVALID-VERIFIER)))
    
    ;; Check if verifier is approved
    (asserts! (get approved verifier-info) ERR-INVALID-VERIFIER)
    ;; Check if batch is not already verified
    (asserts! (not (get verified batch)) ERR-ALREADY-VERIFIED)
    
    ;; Update batch to verified status
    (map-set credit-batches
      { batch-id: batch-id }
      (merge batch { verified: true })
    )
    
    (ok true)))

;; Transfer carbon credits
(define-public (transfer (batch-id uint) (amount uint) (recipient principal))
  (let ((sender-balance (default-to { amount: u0 } (map-get? balances { owner: tx-sender, batch-id: batch-id })))
        (batch (unwrap! (map-get? credit-batches { batch-id: batch-id }) ERR-CREDIT-NOT-FOUND))
        (recipient-balance (default-to { amount: u0 } (map-get? balances { owner: recipient, batch-id: batch-id }))))
    
    ;; Check if the amount is positive
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    ;; Check if sender has enough balance
    (asserts! (>= (get amount sender-balance) amount) ERR-INSUFFICIENT-BALANCE)
    ;; Check if credits are verified
    (asserts! (get verified batch) ERR-NOT-VERIFIED)
    ;; Check if credits are not retired
    (asserts! (not (get retired batch)) ERR-ALREADY-RETIRED)
    
    ;; Update sender balance
    (map-set balances
      { owner: tx-sender, batch-id: batch-id }
      { amount: (- (get amount sender-balance) amount) }
    )
    
    ;; Update recipient balance
    (map-set balances
      { owner: recipient, batch-id: batch-id }
      { amount: (+ (get amount recipient-balance) amount) }
    )
    
    (ok true)))

;; Retire carbon credits (permanently remove them from circulation)
(define-public (retire-credits (batch-id uint) (amount uint))
  (let ((sender-balance (default-to { amount: u0 } (map-get? balances { owner: tx-sender, batch-id: batch-id })))
        (batch (unwrap! (map-get? credit-batches { batch-id: batch-id }) ERR-CREDIT-NOT-FOUND)))
    
    ;; Check if the amount is positive
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    ;; Check if sender has enough balance
    (asserts! (>= (get amount sender-balance) amount) ERR-INSUFFICIENT-BALANCE)
    ;; Check if credits are verified
    (asserts! (get verified batch) ERR-NOT-VERIFIED)
    ;; Check if credits are not already retired
    (asserts! (not (get retired batch)) ERR-ALREADY-RETIRED)
    
    ;; Update sender balance
    (map-set balances
      { owner: tx-sender, batch-id: batch-id }
      { amount: (- (get amount sender-balance) amount) }
    )
    
    ;; Mark batch as retired if all credits are retired
    (if (is-eq amount (get amount batch))
        (map-set credit-batches
          { batch-id: batch-id }
          (merge batch { retired: true })
        )
        true
    )
    
    (ok true)))

;; Read-only functions

;; Get credit type details
(define-read-only (get-credit-type (credit-type-id uint))
  (map-get? credit-types { credit-type-id: credit-type-id }))

;; Get batch details
(define-read-only (get-batch (batch-id uint))
  (map-get? credit-batches { batch-id: batch-id }))

;; Get user balance for a specific batch
(define-read-only (get-balance (owner principal) (batch-id uint))
  (default-to { amount: u0 } (map-get? balances { owner: owner, batch-id: batch-id })))

;; Check if a principal is an approved verifier
(define-read-only (is-verifier (verifier principal))
  (let ((verifier-info (default-to { approved: false, name: "" } (map-get? verifiers { verifier: verifier }))))
    (get approved verifier-info)))

;; Get the total number of credit types
(define-read-only (get-credit-type-count)
  (var-get last-credit-type-id))

;; Get the total number of batches
(define-read-only (get-batch-count)
  (var-get last-batch-id))