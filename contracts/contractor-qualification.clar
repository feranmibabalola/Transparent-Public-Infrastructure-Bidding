;; contractor-qualification.clar
;; This contract validates bidder capabilities

(define-map contractors
  { address: principal }
  {
    name: (string-utf8 100),
    qualifications: (string-utf8 1000),
    experience: uint,
    verified: bool
  }
)

(define-public (register-contractor (name (string-utf8 100))
                                   (qualifications (string-utf8 1000))
                                   (experience uint))
  (begin
    (map-set contractors
      { address: tx-sender }
      {
        name: name,
        qualifications: qualifications,
        experience: experience,
        verified: false
      }
    )
    (ok true)
  )
)

(define-public (verify-contractor (contractor principal))
  (begin
    (asserts! (is-eq tx-sender contract-caller) (err u403))
    (match (map-get? contractors { address: contractor })
      contractor-data (begin
        (map-set contractors
          { address: contractor }
          (merge contractor-data { verified: true })
        )
        (ok true)
      )
      (err u404)
    )
  )
)

(define-read-only (get-contractor (contractor principal))
  (ok (map-get? contractors { address: contractor }))
)

(define-read-only (is-qualified (contractor principal))
  (match (map-get? contractors { address: contractor })
    contractor-data (ok (get verified contractor-data))
    (ok false)
  )
)
