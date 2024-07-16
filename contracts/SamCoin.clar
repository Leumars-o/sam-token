;; Constant Definitions for Voting Power Calculation
(define-constant VOTING_POWER_DECIMALS 18)
(define-constant VOTING_POWER_UNIT (pow 10 VOTING_POWER_DECIMALS))
(define-constant VOTING_COOLDOWN_SECONDS 604800) ;; 1 week in seconds


;; Public Function: Vote on a Proposal
(define-public (vote-for-proposal (proposal-id uint) (choice bool))
  (try
    (let ((voter (get-caller))
          (proposal (get-proposal proposal-id))
          (votes (get-votes proposal-id))
          (has-voted (get-has-voted voter proposal-id))
          (last-vote-timestamp (get-last-vote-timestamp voter proposal-id))
          (current-timestamp (get-block-height))
          (voting-power (get-voting-power voter))
          (is-cooldown-over (is-greater-than current-timestamp (uint-add last-vote-timestamp VOTING_COOLDOWN_SECONDS))))

      (if (is-equal has-voted true) ;; User already voted
        (if (is-equal is-cooldown-over true)
          (begin
            (put-votes proposal-id (map-set votes voter choice))
            (put-has-voted voter proposal-id true)
            (put-last-vote-timestamp voter proposal-id current-timestamp)
            (emit-vote-cast (proposal-id) (voter) (choice) (voting-power))
            (ok true) ;; Success
          )
          (err "You can only vote once every week") ;; Error: proposal closed
        )
        (begin
          (if (is-equal proposal.status "open")
            (begin
              (put-votes proposal-id (map-set votes voter choice))
              (put-has-voted voter proposal-id true)
              (put-last-vote-timestamp voter proposal-id current-timestamp)
              (emit-vote-cast (proposal-id) (voter) (choice) (voting-power))
              (ok true)
            )
            (err "This proposal is not open for voting")
          )
        )
      )
    )
    (catch (e)
      (if (is-equal e "Proposal not found")
        (err "Proposal not found")
        (err "Invalid input")
      )
    )
  )
)

;; Public Functions: Get Vote Counts
(define-public (get-votes-for-proposal (proposal-id uint))
  (let ((votes (get-votes proposal-id)))
    (ok (map-get votes true))
  )
)

;; Private Functions: Data Retrieval
(define-public (get-votes-against-proposal (proposal-id uint))
  (let ((votes (get-votes proposal-id)))
    (ok (map-get votes false))
  )
)

(define-private (get-proposal (proposal-id uint))
  (let ((proposals (get-proposals))
        (proposal (map-get proposals proposal-id)))
    (if (is-none proposal)
      (err "Proposal not found")
      (ok proposal)
    )
  )
)

(define-private (get-proposals)
  (var proposals (map))
  (let ((storage (get-storage))
        (proposals-key (concat "proposals" (uint-to-string proposal-id))))
    (if (is-none (map-get storage proposals-key))
      (ok proposals)
      (ok (map-from-buffer (map-get storage proposals-key)))
    )
  )
)

(define-private (get-votes (proposal-id uint))
  (var votes (map))
  (let ((storage (get-storage))
        (votes-key (concat "votes" (uint-to-string proposal-id))))
    (if (is-none (map-get storage votes-key))
      (ok votes)
      (ok (map-from-buffer (map-get storage votes-key)))
    )
  )
)

(define-private (get-has-voted (voter principal) (proposal-id uint))
  (let ((storage (get-storage))
        (has-voted-key (concat "has-voted" (principal-to-string voter) (uint-to-string proposal-id))))
    (if (is-none (map-get storage has-voted-key))
      (ok false)
      (ok (map-get storage has-voted-key))
    )
  )
)

(define-private (put-votes (proposal-id uint) (votes map))
  (let ((storage (get-storage))
        (votes-key (concat "votes" (uint-to-string proposal-id))))
    (put-storage votes-key (map-to-buffer votes))
    (ok true)
  )
)

(define-private (put-has-voted (voter principal) (proposal-id uint) (has-voted bool))
  (let ((storage (get-storage))
        (has-voted-key (concat "has-voted" (principal-to-string voter) (uint-to-string proposal-id))))
    (put-storage has-voted-key has-voted)
    (ok true)
  )
)

(define-private (get-last-vote-timestamp (voter principal) (proposal-id uint))
  (let ((storage (get-storage))
        (last-vote-timestamp-key (concat "last-vote-timestamp" (principal-to-string voter) (uint-to-string proposal-id))))
    (if (is-none (map-get storage last-vote-timestamp-key))
      (ok 0)
      (ok (map-get storage last-vote-timestamp-key))
    )
  )
)

(define-private (put-last-vote-timestamp (voter principal) (proposal-id uint) (timestamp uint))
  (let ((storage (get-storage))
        (last-vote-timestamp-key (concat "last-vote-timestamp" (principal-to-string voter) (uint-to-string proposal-id))))
    (put-storage last-vote-timestamp-key timestamp)
    (ok true)
  )
)

(define-private (get-voting-power (voter principal))
  (let ((balance (get-balance voter)))
    (ok (uint-div (uint-mul balance VOTING_POWER_UNIT) (get-total-supply)))
  )
)

(define-private (get-balance (voter principal))
  (let ((storage (get-storage))
        (balance-key (concat "balance" (principal-to-string voter))))
    (if (is-none (map-get storage balance-key))
      (ok 0)
      (ok (map-get storage balance-key))
    )
  )
)
