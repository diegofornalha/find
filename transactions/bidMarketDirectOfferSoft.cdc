import FindMarketDirectOfferSoft from "../contracts/FindMarketDirectOfferSoft.cdc"
import FindMarket from "../contracts/FindMarket.cdc"
import FungibleToken from "../contracts/standard/FungibleToken.cdc"
import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import MetadataViews from "../contracts/standard/MetadataViews.cdc"
import FindViews from "../contracts/FindViews.cdc"
import FTRegistry from "../contracts/FTRegistry.cdc"
import NFTRegistry from "../contracts/NFTRegistry.cdc"
import FIND from "../contracts/FIND.cdc"

transaction(marketplace:Address, user: String, nftAliasOrIdentifier: String, id: UInt64, ftAliasOrIdentifier:String, amount: UFix64, validUntil: UFix64?) {

	let targetCapability : Capability<&{NonFungibleToken.Receiver}>
	let walletReference : &FungibleToken.Vault
	let bidsReference: &FindMarketDirectOfferSoft.MarketBidCollection?
	let balanceBeforeBid: UFix64
	let pointer: FindViews.ViewReadPointer
	let ftVaultType: Type

	prepare(account: AuthAccount) {
		
		let resolveAddress = FIND.resolve(user)
		if resolveAddress == nil {panic("The address input is not a valid name nor address. Input : ".concat(user))}
		let address = resolveAddress!

		let nft = NFTRegistry.getNFTInfo(nftAliasOrIdentifier) ?? panic("This NFT is not supported by the Find Market yet")
		let ft = FTRegistry.getFTInfo(ftAliasOrIdentifier) ?? panic("This FT is not supported by the Find Market yet")

		self.ftVaultType = ft.type

		self.targetCapability= account.getCapability<&{NonFungibleToken.Receiver}>(nft.publicPath)
		self.walletReference = account.borrow<&FungibleToken.Vault>(from: ft.vaultPath) ?? panic("No suitable wallet linked for this account")

		let tenant=FindMarket.getTenant(marketplace)
		let storagePath=tenant.getStoragePath(Type<@FindMarketDirectOfferSoft.MarketBidCollection>())!
		self.bidsReference= account.borrow<&FindMarketDirectOfferSoft.MarketBidCollection>(from: storagePath)
		self.balanceBeforeBid=self.walletReference.balance
		self.pointer= FindViews.createViewReadPointer(address: address, path:nft.publicPath, id: id)

		/* Check for nftCapability */
		if !self.targetCapability.check() {
			let cd = self.pointer.getNFTCollectionData()
			// should use account.type here instead
			if account.borrow<&AnyResource>(from: cd.storagePath) != nil {
				panic("This collection public link is not set up properly.")
			}
			account.save(<- cd.createEmptyCollection(), to: cd.storagePath)
			account.link<&{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(cd.publicPath, target: cd.storagePath)
			account.link<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(cd.providerPath, target: cd.storagePath)
		}
	}

	pre {
		self.bidsReference != nil : "This account does not have a bid collection"
		self.walletReference.balance > amount : "Your wallet does not have enough funds to pay for this item"
	}

	execute {
		self.bidsReference!.bid(item:self.pointer, amount: amount, vaultType: self.ftVaultType, nftCap: self.targetCapability, validUntil: validUntil, saleItemExtraField: {}, bidExtraField: {})
	}
}