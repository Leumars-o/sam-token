# SamCoin Voting Contract

This Clarity contract implements a simple voting system for proposals. It allows users to vote on proposals and track the vote counts.

## Features

* **Voting:** Users can vote for or against a proposal.
* **Vote Tracking:** The contract keeps track of the number of votes for and against each proposal.
* **Proposal Status:** Proposals can be in an "open" or "closed" state. Only open proposals can be voted on.
* **Preventing Double Voting:** Users can only vote on a proposal once.

## Contract Functions

* **`vote-for-proposal(proposal-id uint, choice bool)`:** Allows a user to vote on a proposal.
    * `proposal-id`: The unique identifier of the proposal.
    * `choice`: A boolean value representing the user's vote (true for yes, false for no).
* **`get-votes-for-proposal(proposal-id uint)`:** Returns the number of votes for a proposal.
* **`get-votes-against-proposal(proposal-id uint)`:** Returns the number of votes against a proposal.

## Private Functions

* **`get-proposal(proposal-id uint)`:** Retrieves a proposal based on its ID.
* **`get-proposals()`:** Retrieves all proposals from storage.
* **`get-votes(proposal-id uint)`:** Retrieves the votes for a specific proposal.
* **`get-has-voted(voter principal, proposal-id uint)`:** Checks if a user has already voted on a proposal.
* **`put-votes(proposal-id uint, votes map)`:** Updates the votes for a proposal in storage.
* **`put-has-voted(voter principal, proposal-id uint, has-voted bool)`:** Updates the `has-voted` flag for a user in storage.

## Usage

1. **Create a proposal:** You would need a separate function to create proposals and store them in the `proposals` map. This function should set the `status` of the proposal to "open".
2. **Vote on a proposal:** Call the `vote-for-proposal` function with the proposal ID and your choice (true or false).
3. **Retrieve vote counts:** Use `get-votes-for-proposal` and `get-votes-against-proposal` to get the number of votes for and against a proposal.

## Note

* This contract assumes that proposals have a `status` field that can be "open" or "closed".
* You will need to implement the logic for creating and managing proposals separately.
* This is a basic example, and you may need to add more features or modify it to fit your specific needs.

## Example

```
// Create a proposal with ID 1 and status "open"
(define-public (create-proposal (description text))
  (let ((proposals (get-proposals))
        (proposal-id (uint-add (map-size proposals) 1)))
    (put-proposals (map-set proposals proposal-id { description: description, status: "open" }))
    (ok proposal-id)
  )
)

// Vote for proposal 1
(vote-for-proposal 1 true)

// Get the number of votes for proposal 1
(get-votes-for-proposal 1)
```

## STX Token Integration (Future Exploration):

Voting Fee: Require users to pay a small STX fee to vote on a proposal. This can discourage spam and ensure users have a stake in the voting process.
Weighted Voting: Assign voting weight based on STX token holdings. Users with more STX would have a greater influence on the vote outcome. (This approach requires careful consideration to avoid issues like plutocracy)
Governance Token: Transform the proposal system into a Decentralized Autonomous Organization (DAO) where STX token holders govern the platform through proposals and voting.