import FindMarketTenant from "../contracts/FindMarketTenant.cdc"
import FindMarketAuctionEscrow from "../contracts/FindMarketAuctionEscrow.cdc"
import FungibleToken from "../contracts/standard/FungibleToken.cdc"
import FTRegistry from "../contracts/FTRegistry.cdc"

transaction(id: UInt64, amount: UFix64) {

	let walletReference : &FungibleToken.Vault
	let bidsReference: &FindMarketAuctionEscrow.MarketBidCollection
	let balanceBeforeBid: UFix64

	prepare(account: AuthAccount) {

		// Get the accepted vault type from BidInfo
		let tenant=FindMarketTenant.getFindTenantCapability().borrow() ?? panic("Cannot borrow reference to tenant")
		let storagePath=tenant.getStoragePath(Type<@FindMarketAuctionEscrow.MarketBidCollection>())!
		self.bidsReference= account.borrow<&FindMarketAuctionEscrow.MarketBidCollection>(from: storagePath) ?? panic("This account does not have a bid collection")
		let bidInfo = self.bidsReference.getBid(id)
		let saleInformation = bidInfo.item
		let ftIdentifier = saleInformation.ftTypeIdentifier

		//If this is nil, there must be something wrong with FIND setup
		let ft = FTRegistry.getFTInfoByTypeIdentifier(ftIdentifier)!
		self.walletReference = account.borrow<&FungibleToken.Vault>(from: ft.vaultPath) ?? panic("No suitable wallet linked for this account")
		self.balanceBeforeBid = self.walletReference.balance
	}

	pre {
		self.walletReference.balance > amount : "Your wallet does not have enough funds to pay for this item"
	}

	execute {
		let vault <- self.walletReference.withdraw(amount: amount) 
		self.bidsReference!.increaseBid(id: id, vault: <- vault)
	}

	post {
		self.walletReference.balance == self.balanceBeforeBid - amount
	}
}
