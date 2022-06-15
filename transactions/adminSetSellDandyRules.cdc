import FindMarket from "../contracts/FindMarket.cdc"
import Admin from "../contracts/Admin.cdc"
import FlowToken from "../contracts/standard/FlowToken.cdc"
import FUSD from "../contracts/standard/FUSD.cdc"
import Dandy from "../contracts/Dandy.cdc"

transaction(tenant: Address) {
	let adminRef: &Admin.AdminProxy
	prepare(account: AuthAccount){
		self.adminRef = account.borrow<&Admin.AdminProxy>(from: Admin.AdminProxyStoragePath) ?? panic("Cannot borrow Admin Reference.")
	}
	execute{
		let fusdRules=[
		FindMarket.TenantRule(name:"FUSD", types:[Type<@FUSD.Vault>()], ruleType: "ft", allow: true),
		FindMarket.TenantRule(name:"Dandy", types:[ Type<@Dandy.NFT>()], ruleType: "nft", allow: true)
		]

		let fusdDandy = FindMarket.TenantSaleItem(name:"FUSDDandy", cut: nil, rules:fusdRules, status: "active")

		let flowRules=[
		FindMarket.TenantRule(name:"Flow", types:[Type<@FlowToken.Vault>()], ruleType: "ft", allow: true),
		FindMarket.TenantRule(name:"Dandy", types:[ Type<@Dandy.NFT>()], ruleType: "nft", allow: true)
		] 

		let flowDandy = FindMarket.TenantSaleItem(name:"FlowDandy", cut: nil, rules:flowRules,	status: "active")

		self.adminRef.setMarketOption(tenant: tenant, saleItem: fusdDandy)
		self.adminRef.setMarketOption(tenant: tenant, saleItem: flowDandy)

	}
}
