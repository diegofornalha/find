import FIND from "../contracts/FIND.cdc"
import Admin from "../contracts/Admin.cdc"
import Profile from "../contracts/Profile.cdc"

transaction(names: [String], user: Address) {

	let profileCap : Capability<&{Profile.Public}>
	let leaseCollectionCap : Capability<&FIND.LeaseCollection{FIND.LeaseCollectionPublic}>
	let adminClient: &Admin.AdminProxy

	prepare(account: AuthAccount) {
		let userAccount=getAccount(user)
		self.profileCap = userAccount.getCapability<&{Profile.Public}>(Profile.publicPath)
		self.leaseCollectionCap=userAccount.getCapability<&FIND.LeaseCollection{FIND.LeaseCollectionPublic}>(FIND.LeasePublicPath)
		self.adminClient=account.borrow<&Admin.AdminProxy>(from: Admin.AdminProxyStoragePath)!
	}

	pre {
		self.profileCap.check() : "Profile must exist"
		self.leaseCollectionCap.check() : "Find leases must exist"
	}

	execute{
		for name in names {
			self.adminClient.register(name: name,  profile: self.profileCap, leases: self.leaseCollectionCap)
		}
	}
}

