Tasks
Create your contract under the ./contracts/erc20-1 folder:
. Import and inherit from OpenZeppelin ERC20.sol contract
. Choose your token NAME and SYMBOl
. Set a contract owner upon deployment
. Implement an external mint() function which can be called only from owner

Testing:
. Deploy your contract from the deployer account
. Mint 100K tokens to yourself (Deployer)
. Mint 5K tokens to each one of the users
. Verify with a test that every user has the right amount of tokens
. Transfer 100 tokens from User2 to User3
. From User3: approve User1 to spend 1K tokens
. Test that User1 has the right allowance that was given by User3
. From User1: using transferFrom(), transfer 1K tokens from User3