# Carbon Credit Trading System - Vitest Testing Guide

This guide explains how to set up and run the Vitest tests for the Carbon Credit Trading System smart contract.

## Prerequisites

Before running the tests, you need to install Vitest:

```bash
npm install -D vitest
```

## Test Structure

The tests are structured to validate the core functionality of the Carbon Credit Trading System using mocks that simulate the smart contract behavior.

### Test Setup

The test file is organized with these key components:

1. **Mock State**: Represents the state of the smart contract
2. **Mock Functions**: Simulates the behavior of the smart contract functions
3. **Test Cases**: Organized by functionality

## Running the Tests

Run the tests with the following command:

```bash
npx vitest
```

You can also run tests in watch mode:

```bash
npx vitest --watch
```

Or run with UI:

```bash
npx vitest --ui
```

## Test Coverage

The tests cover all key functionality of the Carbon Credit Trading System:

1. **Credit Type Management**
   - Registration of new credit types
   - Retrieval of credit type details

2. **Verifier Management**
   - Registration of verifiers
   - Verification of registered verifiers

3. **Carbon Credit Issuance**
   - Issuing new carbon credits
   - Retrieving batch details
   - Checking balances

4. **Credit Verification**
   - Verifying carbon credits
   - Checking verification status
   - Testing authorization controls

5. **Credit Transfer**
   - Transferring credits between accounts
   - Checking balance updates after transfers
   - Testing transfer restrictions

6. **Credit Retirement**
   - Retiring carbon credits
   - Checking balance updates after retirement
   - Testing full batch retirement

## Using the Mock Functions

The mock functions provide a simulated environment for testing the contract's behavior without requiring a blockchain connection. They maintain state in memory and provide the same interface as the actual contract functions.

Key mock functions include:

- `mockRegisterCreditType`: Register a new carbon credit type
- `mockRegisterVerifier`: Register a verifier entity
- `mockIssueCredits`: Issue new carbon credits
- `mockVerifyBatch`: Verify a batch of carbon credits
- `mockTransfer`: Transfer credits between accounts
- `mockRetireCredits`: Retire carbon credits
- `mockGetBalance`: Get an account's balance for a specific batch
- `mockGetBatch`: Get details about a specific batch
- `mockIsVerifier`: Check if an address is a registered verifier

## Extending the Tests

When adding new features to the contract, you can extend the tests by:

1. Adding new mock functions to simulate the new contract functionality
2. Adding new test groups with `describe()`
3. Creating specific test cases with `it()`

## Integration with Clarity Contract Testing

For a complete testing strategy, you should use both:

1. These Vitest tests for behavior validation
2. Clarity test files for on-chain contract logic testing

This dual approach ensures both the contract logic and application behavior are thoroughly tested.

## Next Steps

After ensuring all tests pass, you can:

1. Add more detailed tests for edge cases
2. Implement integration tests with actual contract deployment
3. Build a frontend application that interacts with the contract
d to install the required dependencies:

```bash
npm install -D vitest @stacks/transactions @stacks/network
```

## Test Setup

The Vitest tests are designed to work with a local Stacks blockchain environment. The tests interact with your smart contract deployed on a local Stacks blockchain.

### Setting Up the Local Environment

1. Start your local Clarinet development environment:

```bash
clarinet integrate
```

2. In another terminal window, start a local Stacks API node:

```bash
clarinet dev
```

This will start a local Stacks blockchain environment on port 3999.

## Configuration

The tests are configured to work with a local Stacks blockchain with these default settings:

- API URL: `http://localhost:3999`
- Contract address: `ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM`
- Contract name: `carbon-credit-trading`

If you need to change these settings, modify the configuration section at the top of the test file.

## Test Account Details

The tests use several pre-defined accounts with test STX:

- **DEPLOYER**: The account that deployed the contract
- **ISSUER**: Account used for issuing carbon credits
- **VERIFIER**: Account used for verifying carbon credits
- **BUYER**: Account used for purchasing carbon credits

These accounts have pre-funded STX balances in the local development environment.

## Running the Tests

Run the tests with the following command:

```bash
npx vitest
```

You can also run tests in watch mode:

```bash
npx vitest --watch
```

Or run with UI:

```bash
npx vitest --ui
```

## Test Coverage

The tests cover all key functionality of the Carbon Credit Trading System:

1. **Credit Type Management**
   - Registration of new credit types
   - Retrieval of credit type details

2. **Verifier Management**
   - Registration of verifiers
   - Verification of registered verifiers

3. **Carbon Credit Issuance**
   - Issuing new carbon credits
   - Retrieving batch details
   - Checking balances

4. **Credit Verification**
   - Verifying carbon credits
   - Checking verification status
   - Testing authorization controls

5. **Credit Transfer**
   - Transferring credits between accounts
   - Checking balance updates after transfers
   - Testing transfer restrictions

6. **Credit Retirement**
   - Retiring carbon credits
   - Checking balance updates after retirement
   - Testing full batch retirement

## Extending the Tests

When you add new features to the contract, you can extend the tests by:

1. Adding new test groups with `describe()`
2. Creating specific test cases with `it()`
3. Using the helper functions for transaction submission and contract reading

## Troubleshooting

If you encounter issues running the tests:

1. **Connection errors**: Make sure your local Stacks blockchain is running (`clarinet dev`)
2. **Transaction errors**: Check if the test accounts have enough STX balance
3. **Contract errors**: Verify your contract code is correctly deployed
4. **Nonce errors**: If you're seeing nonce-related errors, you may need to restart your local blockchain

## Next Steps

After ensuring all tests pass, you can proceed with:

1. Deploying your contract to testnet
2. Developing a frontend application
3. Implementing additional features like the carbon credit marketplace