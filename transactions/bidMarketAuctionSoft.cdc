import FindMarketTenant from "../contracts/FindMarketTenant.cdc"
import FindMarketAuctionSoft from "../contracts/FindMarketAuctionSoft.cdc"
import FungibleToken from "../contracts/standard/FungibleToken.cdc"
import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import FindViews from "../contracts/FindViews.cdc"
import MetadataViews from "../contracts/standard/MetadataViews.cdc"
import FTRegistry from "../contracts/FTRegistry.cdc"
import NFTRegistry from "../contracts/NFTRegistry.cdc"

transaction(address: Address, id: UInt64, amount: UFix64) {

	let saleItemsCap: Capability<&FindMarketAuctionSoft.SaleItemCollection{FindMarketAuctionSoft.SaleItemCollectionPublic}> 
	let targetCapability : Capability<&{NonFungibleToken.Receiver}>
	let walletReference : &FungibleToken.Vault
	let bidsReference: &FindMarketAuctionSoft.MarketBidCollection?
	let balanceBeforeBid: UFix64
	let pointer: FindViews.ViewReadPointer
	let ftVaultType: Type

	prepare(account: AuthAccount) {

		self.saleItemsCap= FindMarketAuctionSoft.getFindSaleItemCapability(address) ?? panic("cannot find sale item cap")
		let saleInformation =self.saleItemsCap.borrow()!.getItemForSaleInformation(id)

		let nft = NFTRegistry.getNFTInfoByTypeIdentifier(saleInformation.type.identifier) ?? panic("This NFT is not supported by the Find Market yet")
		let ft = FTRegistry.getFTInfoByTypeIdentifier(saleInformation.ftTypeIdentifier) ?? panic("This FT is not supported by the Find Market yet")

		self.targetCapability= account.getCapability<&{NonFungibleToken.Receiver}>(nft.publicPath)
		self.walletReference = account.borrow<&FungibleToken.Vault>(from: ft.vaultPath) ?? panic("No FUSD wallet linked for this account")
		self.ftVaultType = ft.type

		let tenant=FindMarketTenant.getFindTenantCapability().borrow() ?? panic("Cannot borrow reference to tenant")
		let storagePath=tenant.getStoragePath(Type<@FindMarketAuctionSoft.MarketBidCollection>())!

		self.bidsReference= account.borrow<&FindMarketAuctionSoft.MarketBidCollection>(from: storagePath)
		self.balanceBeforeBid=self.walletReference.balance
		self.pointer= FindViews.createViewReadPointer(address: address, path:nft.publicPath, id: id)
	}

	pre {
		self.bidsReference != nil : "This account does not have a bid collection"
		self.walletReference.balance > amount : "Your wallet does not have enough funds to pay for this item"
		self.targetCapability.check() : "The target collection for the item your are bidding on does not exist"
	}

	execute {
		self.bidsReference!.bid(item:self.pointer, amount: amount, vaultType: self.ftVaultType, nftCap: self.targetCapability)
	}
}