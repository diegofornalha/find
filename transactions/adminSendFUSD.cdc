import FungibleToken from "../contracts/standard/FungibleToken.cdc"
import FUSD from "../contracts/standard/FUSD.cdc"

transaction(receiver: Address, amount:UFix64) {

	let receiver: &FUSD.Vault{FungibleToken.Receiver}
	let sender: &FUSD.Vault

	prepare(acct: AuthAccount) {
		self.receiver = getAccount(receiver).getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver).borrow() ?? panic("Cannot borrow FUSD receiver")
		self.sender = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault) ?? panic("Cannot borrow FUSD vault from authAcct storage")
	}
	pre {
		self.sender.balance > amount : "Sender does not have enough funds"
	}

	execute {
		self.receiver.deposit(from: <- self.sender.withdraw(amount:amount))
	}
}
