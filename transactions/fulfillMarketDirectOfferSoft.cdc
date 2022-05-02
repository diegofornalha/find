import FindMarketDirectOfferSoft from "../contracts/FindMarketDirectOfferSoft.cdc"
import FindMarketTenant from "../contracts/FindMarketTenant.cdc"
import FungibleToken from "../contracts/standard/FungibleToken.cdc"
import FTRegistry from "../contracts/FTRegistry.cdc"

//TODO: should these include the amount for safety reason, i belive they should
transaction(id: UInt64) {

	let walletReference : &FungibleToken.Vault
	let balanceBeforeFulfill: UFix64
	let bidsReference: &FindMarketDirectOfferSoft.MarketBidCollection

	prepare(account: AuthAccount) {
		let tenant=FindMarketTenant.getFindTenantCapability().borrow() ?? panic("Cannot borrow reference to tenant")
		let storagePath=tenant.getStoragePath(Type<@FindMarketDirectOfferSoft.MarketBidCollection>())

		self.bidsReference= account.borrow<&FindMarketDirectOfferSoft.MarketBidCollection>(from: storagePath) ?? panic("Cannot borrow direct offer soft bid collection")

		let ftIdentifier = self.bidsReference.getBid(id).item.ftTypeIdentifier
		let ft = FTRegistry.getFTInfoByTypeIdentifier(ftIdentifier)!

		self.walletReference = account.borrow<&FungibleToken.Vault>(from: ft.vaultPath) ?? panic("No suitable wallet linked for this account")
		self.balanceBeforeFulfill=self.walletReference.balance

	}

	execute {
		let amount = self.bidsReference.getBalance(id)
		let vault <- self.walletReference.withdraw(amount: amount) 
		self.bidsReference.fulfillDirectOffer(id: id, vault: <- vault)
	}
}
