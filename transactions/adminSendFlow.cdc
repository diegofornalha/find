import FungibleToken from "../contracts/standard/FungibleToken.cdc"
import FlowToken from "../contracts/standard/FlowToken.cdc"

transaction(receiver: Address, amount:UFix64) {

	let receiver: &FlowToken.Vault{FungibleToken.Receiver}
	let sender: &FlowToken.Vault

	prepare(acct: AuthAccount) {
		self.receiver = getAccount(receiver).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver).borrow() ?? panic("Cannot borrow FlowToken receiver")

		self.sender = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) ?? panic("Cannot borrow FlowToken vault from authAcct storage")
	}

	pre {
		self.sender.balance > amount : "Sender does not have enough funds"
	}

	execute {
		self.receiver.deposit(from: <- self.sender.withdraw(amount:amount))
	}
}
