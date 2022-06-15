import Profile from "../contracts/Profile.cdc"
import FIND from "../contracts/FIND.cdc"

transaction(user: String) {

	let profile : &Profile.User

	prepare(acct: AuthAccount) {
		self.profile =acct.borrow<&Profile.User>(from:Profile.storagePath)!
	}

	execute {
		let address =FIND.resolve(user) ?? panic("Not a registered name or valid address.")
		self.profile.addBan(address)

	}
}

