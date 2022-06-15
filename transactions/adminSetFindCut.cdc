import Admin from "../contracts/Admin.cdc"

transaction(tenant: Address, cut: UFix64){

	let adminClient: &Admin.AdminProxy

	prepare(account: AuthAccount){
		self.adminClient = account.borrow<&Admin.AdminProxy>(from: Admin.AdminProxyStoragePath) ?? panic("Cannot borrow Admin Reference.")
	}

	execute{
		self.adminClient.setFindCut(tenant: tenant, cut: cut, rules: nil, status: "active")
	}
}

