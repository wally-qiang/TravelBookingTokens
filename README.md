# TravelBookingTokens (TBT)

A comprehensive token reward distribution smart contract for travel platform booking rewards on the Stacks blockchain.

## 🌟 Overview

TravelBookingTokens is a fungible token smart contract that incentivizes travel bookings by distributing TBT tokens as rewards. The contract implements SIP-010 standard functions and provides a robust framework for managing booking rewards, token distribution, and platform incentives.

## ✨ Features

### Core Token Features
- **SIP-010 Compliant**: Implements standard fungible token interface
- **Token Metadata**: Name (TravelBookingToken), Symbol (TBT), Decimals (6)
- **Secure Transfers**: Built-in authorization checks and balance validation
- **Minting Controls**: Owner-only minting with supply tracking

### Reward Distribution System
- **Booking Rewards**: Automatic token distribution for completed bookings
- **Claim Bonuses**: Additional 10% bonus tokens for claiming rewards
- **Reward Tracking**: Comprehensive tracking of user rewards and booking history
- **Duplicate Prevention**: Prevents duplicate reward claims for the same booking

### Administrative Controls
- **Authorized Distributors**: Multi-distributor support for scalable operations
- **Reward Rate Management**: Adjustable reward rates (default: 100 TBT per booking)
- **Contract Pause/Unpause**: Emergency controls for contract operations
- **Token URI Management**: Metadata URI configuration

### Security Features
- **Owner-only Functions**: Critical operations restricted to contract owner
- **Authorization Checks**: Multi-level permission system
- **Input Validation**: Comprehensive parameter validation
- **Error Handling**: Detailed error codes and messages

## 🛠 Technical Specifications

### Contract Details
- **Language**: Clarity v2
- **Blockchain**: Stacks
- **Epoch**: 2.5
- **Token Standard**: SIP-010 Fungible Token

### Token Economics
- **Initial Supply**: 0 (mintable)
- **Decimals**: 6
- **Reward Rate**: 100 TBT per booking (100,000,000 micro-tokens)
- **Claim Bonus**: 10% additional tokens

### Error Codes
- `u100`: Owner-only operation
- `u101`: Insufficient balance
- `u102`: Invalid amount
- `u103`: Unauthorized operation
- `u104`: Booking already exists
- `u105`: Booking not found
- `u106`: Reward already claimed

## 🚀 Installation

### Prerequisites
- [Clarinet](https://docs.hiro.so/clarinet) >= 2.0
- [Node.js](https://nodejs.org/) >= 18
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Setup
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd TravelBookingTokens
   ```

2. Install dependencies:
   ```bash
   cd TravelBookingTokens_contract
   npm install
   ```

3. Run tests:
   ```bash
   npm test
   ```

## 📖 Usage Examples

### Token Operations

#### Check Token Balance
```clarity
(contract-call? .TravelBookingTokens get-balance 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

#### Transfer Tokens
```clarity
(contract-call? .TravelBookingTokens transfer u1000000 tx-sender 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG none)
```

### Reward Distribution

#### Distribute Booking Reward
```clarity
(contract-call? .TravelBookingTokens distribute-booking-reward "booking-123" 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

#### Claim Reward Bonus
```clarity
(contract-call? .TravelBookingTokens claim-booking-reward "booking-123")
```

### Administrative Functions

#### Set Reward Rate
```clarity
(contract-call? .TravelBookingTokens set-reward-rate u200000000) ;; 200 TBT per booking
```

#### Authorize Distributor
```clarity
(contract-call? .TravelBookingTokens authorize-distributor 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

## 📋 Contract Functions Documentation

### Public Functions

#### Token Standard Functions
- `transfer(amount, sender, recipient, memo)` - Transfer tokens between accounts
- `mint(amount, recipient)` - Mint new tokens (owner only)

#### Reward Functions
- `distribute-booking-reward(booking-id, user)` - Distribute reward for completed booking
- `claim-booking-reward(booking-id)` - Claim bonus reward for booking

#### Administrative Functions
- `set-reward-rate(new-rate)` - Update reward rate per booking
- `authorize-distributor(distributor)` - Add authorized reward distributor
- `revoke-distributor(distributor)` - Remove distributor authorization
- `pause-contract()` - Pause contract operations
- `unpause-contract()` - Resume contract operations
- `set-token-uri(uri)` - Set metadata URI

### Read-Only Functions

#### Token Information
- `get-name()` - Returns token name
- `get-symbol()` - Returns token symbol
- `get-decimals()` - Returns decimal places
- `get-balance(who)` - Returns account balance
- `get-total-supply()` - Returns total token supply
- `get-token-uri()` - Returns metadata URI

#### Contract State
- `get-reward-rate()` - Current reward rate
- `is-authorized-distributor(distributor)` - Check distributor authorization
- `get-booking-reward(booking-id, user)` - Get booking reward details
- `get-user-total-rewards(user)` - Get user's total earned rewards
- `is-contract-paused()` - Contract pause status
- `get-contract-owner()` - Contract owner address

## 🚢 Deployment Guide

### Testnet Deployment
1. Configure testnet settings in `settings/Testnet.toml`
2. Deploy using Clarinet:
   ```bash
   clarinet integrate
   ```

### Mainnet Deployment
1. Configure mainnet settings in `settings/Mainnet.toml`
2. Prepare deployment transaction:
   ```bash
   clarinet deployments generate --devnet
   ```
3. Execute deployment with appropriate keys and configuration

### Post-Deployment Setup
1. **Set Token URI**: Configure metadata URI for token information
2. **Authorize Distributors**: Add platform backends as authorized distributors
3. **Set Initial Reward Rate**: Configure appropriate reward rate for your platform
4. **Test Integration**: Verify booking reward distribution works correctly

## 🔒 Security Considerations

### Access Controls
- **Owner Privileges**: Only contract owner can mint, set rates, and manage distributors
- **Distributor Authorization**: Only authorized principals can distribute rewards
- **Transfer Restrictions**: Users can only transfer their own tokens or approved amounts

### Operational Security
- **Pause Mechanism**: Emergency pause functionality for critical situations
- **Input Validation**: All functions validate inputs and check preconditions
- **Duplicate Prevention**: Booking rewards cannot be duplicated or double-claimed
- **Balance Checks**: Transfer functions verify sufficient balance before execution

### Best Practices
- **Regular Monitoring**: Monitor contract events and reward distributions
- **Distributor Management**: Regularly review and rotate authorized distributors
- **Rate Management**: Adjust reward rates based on platform economics
- **Emergency Procedures**: Maintain procedures for contract pausing and issue resolution

## 🧪 Testing

The contract includes comprehensive test coverage using Vitest and Clarinet SDK:

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:report

# Watch mode for development
npm run test:watch
```

Test coverage includes:
- Token standard compliance
- Reward distribution logic
- Administrative functions
- Error handling
- Edge cases and security scenarios

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request with detailed description

## 📄 License

This project is licensed under the ISC License - see the package.json for details.

## 🆘 Support

For questions, issues, or support:
- Create an issue in the repository
- Review the contract documentation
- Check test files for usage examples

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**Clarity Version**: 2  
**Stacks Epoch**: 2.5