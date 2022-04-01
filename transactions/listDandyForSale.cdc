import FindMarket from "../contracts/FindMarket.cdc"
import FindMarketSale from "../contracts/FindMarketSale.cdc"
import FlowToken from "../contracts/standard/FlowToken.cdc"
import FUSD from "../contracts/standard/FUSD.cdc"
import NonFungibleToken from "../contracts/standard/NonFungibleToken.cdc"
import MetadataViews from "../contracts/standard/MetadataViews.cdc"
import Dandy from "../contracts/Dandy.cdc"
import FindViews from "../contracts/FindViews.cdc"

transaction(id: UInt64, directSellPrice:UFix64) {
	prepare(account: AuthAccount) {
		let tenant=FindMarket.getFindTenant() 
		let saleItems= account.borrow<&FindMarketSale.SaleItemCollection>(from: tenant.getStoragePath(Type<@FindMarketSale.SaleItemCollection>())!)!
		let dandyPrivateCap=	account.getCapability<&Dandy.Collection{NonFungibleToken.Provider, MetadataViews.ResolverCollection, NonFungibleToken.Receiver}>(Dandy.CollectionPrivatePath)

		let pointer= FindViews.AuthNFTPointer(cap: dandyPrivateCap, id: id)
		saleItems.listForSale(pointer: pointer, vaultType: Type<@FUSD.Vault>(), directSellPrice: directSellPrice)
	}
}