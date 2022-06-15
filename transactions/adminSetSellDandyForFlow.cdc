import FindMarket from "../contracts/FindMarket.cdc"
import Admin from "../contracts/Admin.cdc"
import FlowToken from "../contracts/standard/FlowToken.cdc"
import Dandy from "../contracts/Dandy.cdc"
import FindMarketSale from "../contracts/FindMarketSale.cdc"
import FindMarketAuctionEscrow from "../contracts/FindMarketAuctionEscrow.cdc"
import FindMarketAuctionSoft from "../contracts/FindMarketAuctionSoft.cdc"
import FindMarketDirectOfferEscrow from "../contracts/FindMarketDirectOfferEscrow.cdc"
import FindMarketDirectOfferSoft from "../contracts/FindMarketDirectOfferSoft.cdc"


transaction(tenant: Address, market: String){

	let adminRef : &Admin.AdminProxy

	prepare(account: AuthAccount){
		self.adminRef = account.borrow<&Admin.AdminProxy>(from: Admin.AdminProxyStoragePath) ?? panic("Cannot borrow Admin Reference.")
	}

	execute {
		var marketType : [Type] = [Type<@FindMarketSale.SaleItem>()]
		switch market {
		case "AuctionEscrow" :
			marketType = [Type<@FindMarketAuctionEscrow.SaleItem>()]

		case "AuctionSoft" :
			marketType = [Type<@FindMarketAuctionSoft.SaleItem>()]

		case "DirectOfferEscrow" :
			marketType = [Type<@FindMarketDirectOfferEscrow.SaleItem>()]

		case "DirectOfferSoft" :
			marketType = [Type<@FindMarketDirectOfferSoft.SaleItem>()]
		}

		let rules=[
		FindMarket.TenantRule(name:"Flow", types:[Type<@FlowToken.Vault>()], ruleType: "ft", allow: true),
		FindMarket.TenantRule(name:"Dandy", types:[Type<@Dandy.NFT>()], ruleType: "nft", allow: true),
		FindMarket.TenantRule(name: market, types:marketType, ruleType: "listing", allow: true)
		]
		let saleItem = FindMarket.TenantSaleItem(name:"FlowDandy".concat(market), cut: nil, rules:rules, status: "active")

		self.adminRef.setMarketOption(tenant: tenant, saleItem: saleItem)
	}
}

